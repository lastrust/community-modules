export interface MerkleInfo {
  merkleRoot: string;
}

// This is the blob that gets distributed and pinned to IPFS.
// It is completely sufficient for recreating the entire merkle tree.
export interface MerkleDistributorInfo extends MerkleInfo {
  tokenTotal: string;
  claims: {
    [account: string]: {
      index: number;
      amount: string;
      revocable: boolean;
      proof: string[];
      flags?: {
        [flag: string]: boolean;
      };
    };
  };
}
