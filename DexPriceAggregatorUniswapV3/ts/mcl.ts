// SPDX-License-Identifier: MIT
/* Adapted from https://github.com/thehubbleproject/hubble-contracts/blob/f1c13fe4e1a0dc9ab1f150895de7c0e654ee46b0/ts/
   mcl.ts */
import * as mcl from "mcl-wasm";
import { BigNumber, BigNumberish, ethers } from "ethers";
import { FIELD_ORDER, hashToField } from "./hashToField";
import { randHex } from "./utils";
import { arrayify, hexlify } from "ethers/lib/utils";

export type mclG2 = any;
export type mclG1 = any;
export type mclFP = any;
export type mclFR = any;

export type SecretKey = mclFR;
export type MessagePoint = mclG1;
export type Signature = mclG1;
export type PublicKey = mclG2;

export type solG1 = [BigNumberish, BigNumberish];
export type solG2 = [BigNumberish, BigNumberish, BigNumberish, BigNumberish];

export interface keyPair {
    pubkey: PublicKey;
    secret: SecretKey;
}

export type Domain = Uint8Array;

export async function init() {
    await mcl.init(mcl.BN_SNARK1);
    mcl.setMapToMode(mcl.BN254);
}

export function validateDomain(domain: Domain) {
    if (domain.length != 32) {
        throw new Error("bad domain length");
    }
}

export function hashToPoint(msg: string, domain: Domain): MessagePoint {
    if (!ethers.utils.isHexString(msg)) {
        throw new Error("message is expected to be hex string");
    }

    const _msg = arrayify(msg);
    const [e0, e1] = hashToField(domain, _msg, 2);
    const p0 = mapToPoint(e0);
    const p1 = mapToPoint(e1);
    const p = mcl.add(p0, p1);
    p.normalize();
    return p;
}

export function mapToPoint(e0: BigNumber): mclG1 {
    let e1 = new mcl.Fp();
    e1.setStr(e0.mod(FIELD_ORDER).toString());
    return e1.mapToG1();
}

export function toBigEndian(p: mclFP): Uint8Array {
    // serialize() gets a little-endian output of Uint8Array
    // reverse() turns it into big-endian, which Solidity likes
    return p.serialize().reverse();
}

export function g1(): mclG1 {
    const g1 = new mcl.G1();
    g1.setStr("1 0x01 0x02", 16);
    return g1;
}

export function g2(): mclG2 {
    const g2 = new mcl.G2();
    g2.setStr(
        "1 0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed 0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2 0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa 0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b"
    );
    return g2;
}

export function negativeG2(): mclG2 {
    const g2 = new mcl.G2();
    g2.setStr(
        "1 0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed 0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2 0x1d9befcd05a5323e6da4d435f3b617cdb3af83285c2df711ef39c01571827f9d 0x275dc4a288d1afb3cbb1ac09187524c7db36395df7be3b99e673b13a075a65ec"
    );
    return g2;
}

export function g1ToHex(p: mclG1): solG1 {
    p.normalize();
    const x = hexlify(toBigEndian(p.getX()));
    const y = hexlify(toBigEndian(p.getY()));
    return [x, y];
}

export function g2ToHex(p: mclG2): solG2 {
    p.normalize();
    const x = toBigEndian(p.getX());
    const x0 = hexlify(x.slice(32));
    const x1 = hexlify(x.slice(0, 32));
    const y = toBigEndian(p.getY());
    const y0 = hexlify(y.slice(32));
    const y1 = hexlify(y.slice(0, 32));
    return [x0, x1, y0, y1];
}

export function getPubkey(secret: SecretKey): PublicKey {
    const pubkey: any = mcl.mul(g2(), secret);
    pubkey.normalize();
    return pubkey;
}

export function newKeyPair(): keyPair {
    const secret = randFr();
    const pubkey = getPubkey(secret);
    return { pubkey, secret };
}

export function sign(
    message: string,
    secret: SecretKey,
    domain: Domain
): { signature: Signature; messagePoint: MessagePoint } {
    const messagePoint = hashToPoint(message, domain);
    const signature: any = mcl.mul(messagePoint, secret);
    signature.normalize();
    return { signature, messagePoint };
}

export function aggregateRaw(signatures: Signature[]): Signature {
    let aggregated = new mcl.G1();
    for (const sig of signatures) {
        aggregated = mcl.add(aggregated, sig);
    }
    aggregated.normalize();
    return aggregated;
}

export function aggregatePks(pks: PublicKey[]): PublicKey {
    let aggregated = new mcl.G2();
    for (const pk of pks) {
        aggregated = mcl.add(aggregated, pk);
    }
    aggregated.normalize();
    return aggregated;
}

export function parseFr(hex: string): mclFR {
    if (!ethers.utils.isHexString(hex)) {
        throw new Error("message is expected to be hex string");
    }
    let fr = new mcl.Fr();
    fr.setHashOf(hex);
    return fr;
}

export function randFr(): mclFR {
    const r = randHex(12);
    let fr = new mcl.Fr();
    fr.setHashOf(r);
    return fr;
}

export function mulG2FrInt(point: mclG2, n: number): mclG2 {
    let fr = new mcl.Fr();
    fr.setInt(n);
    return mcl.mul(point, fr);
}

export function randG1(): solG1 {
    const p: any = mcl.mul(g1(), randFr());
    p.normalize();
    return g1ToHex(p);
}

export function randG2(): solG2 {
    const p: any = mcl.mul(g2(), randFr());
    p.normalize();
    return g2ToHex(p);
}

export function parseG1(solG1: solG1): mclG1 {
    const g1 = new mcl.G1();
    const [x, y] = solG1;
    g1.setStr(`1 ${x} ${y}`, 16);
    return g1;
}

export function parseG2(solG2: solG2): mclG2 {
    const g2 = new mcl.G2();
    const [x0, x1, y0, y1] = solG2;
    g2.setStr(`1 ${x0} ${x1} ${y0} ${y1}`);
    return g2;
}

function dump(sol: solG1 | solG2): string {
    return `0x${sol.map((n) => n.toString().slice(2)).join("")}`;
}

export function dumpG1(solG1: solG1): string {
    return dump(solG1);
}

export function dumpG2(solG2: solG2): string {
    return dump(solG2);
}

export function loadG1(hex: string): solG1 {
    const bytesarray = arrayify(hex);
    if (bytesarray.length != 64) throw new Error(`Expect length 64 but got ${bytesarray.length}`);
    const x = hexlify(bytesarray.slice(0, 32));
    const y = hexlify(bytesarray.slice(32));
    return [x, y];
}

export function loadG2(hex: string): solG2 {
    const bytesarray = arrayify(hex);
    if (bytesarray.length != 128) throw new Error(`Expect length 128 but got ${bytesarray.length}`);
    const x0 = hexlify(bytesarray.slice(0, 32));
    const x1 = hexlify(bytesarray.slice(32, 64));
    const y0 = hexlify(bytesarray.slice(64, 96));
    const y1 = hexlify(bytesarray.slice(96, 128));
    return [x0, x1, y0, y1];
}

export function verifyRaw(signature: Signature, pubkey: PublicKey, message: MessagePoint): boolean {
    const negG2 = new mcl.PrecomputedG2(negativeG2());

    const pairings = mcl.precomputedMillerLoop2mixed(message, pubkey, signature, negG2);
    // call this function to avoid memory leak
    negG2.destroy();
    return mcl.finalExp(pairings).isOne();
}