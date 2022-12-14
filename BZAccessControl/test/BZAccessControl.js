const { expect } = require("chai");
const { ethers } = require("hardhat");
const web3 = require("web3");

const ROLE_1 = web3.utils.soliditySha3("ROLE_1");
const ROLE_2 = web3.utils.soliditySha3("ROLE_2");
const DEFAULT_ADMIN_ROLE = '0x0000000000000000000000000000000000000000000000000000000000000000';

describe("Testing Admin Contract", function () {
    // Creating the instance and contract info for the Admin Contract
    let adminInstance, adminContract;
    let bzAccessControlInstance, bzAccessControlContract;

    // Creating the users
    let admin, owner, authorized, other, otherAdmin, otherAuthorized;

    beforeEach(async () => {
        // Getting the users provided by ethers
        [owner, authorized, other, otherAdmin, otherAuthorized] = await ethers.getSigners();

        // Getting the admin contract code (abi, bytecode, name)
        bzAccessControlContract = await ethers.getContractFactory("BZAccessControl");

        // Deploying the instance
        bzAccessControlInstance = await bzAccessControlContract.deploy();

        await bzAccessControlInstance.deployed();

        // Getting the admin contract code (abi, bytecode, name)
        adminContract = await ethers.getContractFactory("AdminContract");

        // Deploying the instance
        adminInstance = await adminContract.deploy();

        await adminInstance.deployed();

        await bzAccessControlInstance.connectToOtherContracts([adminInstance.address]);
        await adminInstance.setAccessControl(bzAccessControlInstance.address);

        admin = adminInstance.address;
    });

    describe('default admin', function () {
        it('deployer has default admin role', async function () {
            expect(await adminInstance.hasRole(DEFAULT_ADMIN_ROLE, admin)).to.equal(true);
        });

        it('other roles\'s admin is the default admin role', async function () {
            expect(await adminInstance.getRoleAdmin(ROLE_1)).to.equal(DEFAULT_ADMIN_ROLE);
        });

        it('default admin role\'s admin is itself', async function () {
            expect(await adminInstance.getRoleAdmin(DEFAULT_ADMIN_ROLE)).to.equal(DEFAULT_ADMIN_ROLE);
        });
    });

    describe('granting', function () {
        beforeEach(async function () {
            await adminInstance.grantRole(ROLE_1, authorized.address);
        });

        it('non-admin cannot grant role to other accounts', async function () {
            await expect(
                bzAccessControlInstance.connect(other).grantRole(ROLE_1, authorized.address)
            ).to.be.revertedWith(
                `BZAccessControl: account ${other.address.toLowerCase()} is missing role ${DEFAULT_ADMIN_ROLE}`,
            );
        });

        it('accounts can be granted a role multiple times', async function () {
            await adminInstance.grantRole(ROLE_1, authorized.address);
            await expect(
                adminInstance.grantRole(ROLE_1, authorized.address)
            ).not.to.be.emit(bzAccessControlInstance, 'RoleGranted');
        });
    });

    describe('revoking', function () {
        it('roles that are not had can be revoked', async function () {
            expect(await adminInstance.hasRole(ROLE_1, authorized.address)).to.equal(false);

            await expect(
                adminInstance.revokeRole(ROLE_1, authorized.address)
            ).not.to.be.emit(bzAccessControlInstance, 'RoleRevoked');
        });

        context('with granted role', function () {
            beforeEach(async function () {
                await adminInstance.grantRole(ROLE_1, authorized.address);
            });

            it('admin can revoke role', async function () {
                await expect(
                    adminInstance.revokeRole(ROLE_1, authorized.address)
                ).to.emit(bzAccessControlInstance, 'RoleRevoked').withArgs(ROLE_1, authorized.address, admin);

                expect(await adminInstance.hasRole(ROLE_1, authorized.address)).to.equal(false);
            });

            it('non-admin cannot revoke role', async function () {
                await expect(
                    bzAccessControlInstance.connect(other).revokeRole(ROLE_1, authorized.address),
                ).to.be.revertedWith(
                    `BZAccessControl: account ${other.address.toLowerCase()} is missing role ${DEFAULT_ADMIN_ROLE}`,
                );
            });

            it('a role can be revoked multiple times', async function () {
                await adminInstance.revokeRole(ROLE_1, authorized.address);

                await expect(
                    adminInstance.revokeRole(ROLE_1, authorized.address)
                ).not.to.be.emit(bzAccessControlInstance, 'RoleRevoked');
            });
        });
    });

    describe('setting role admin', function () {
        beforeEach(async function () {
            await expect(
                adminInstance.setRoleAdmin(ROLE_1, ROLE_2)
            ).to.be.emit(bzAccessControlInstance, 'AdminRoleChanged').withArgs(ROLE_1, DEFAULT_ADMIN_ROLE, ROLE_2);

            await adminInstance.grantRole(ROLE_2, otherAdmin.address);
        });

        it('a role\'s admin role can be changed', async function () {
            expect(await adminInstance.getRoleAdmin(ROLE_1)).to.equal(ROLE_2);
        });

        it('the new admin can grant roles', async function () {
            await expect(
                bzAccessControlInstance.connect(otherAdmin).grantRole(ROLE_1, authorized.address)
            ).to.be.emit(bzAccessControlInstance, 'RoleGranted').withArgs(ROLE_1, authorized.address, otherAdmin.address);
        });

        it('the new admin can revoke roles', async function () {
            await bzAccessControlInstance.connect(otherAdmin).grantRole(ROLE_1, authorized.address);
            await expect(
                bzAccessControlInstance.connect(otherAdmin).revokeRole(ROLE_1, authorized.address)
            ).to.be.emit(bzAccessControlInstance, 'RoleRevoked').withArgs(ROLE_1, authorized.address, otherAdmin.address);
        });

        it('a role\'s previous admins no longer grant roles', async function () {
            await expect(
                adminInstance.grantRole(ROLE_1, authorized.address),
            ).to.be.revertedWith(
                `BZAccessControl: account ${admin.toLowerCase()} is missing role ${ROLE_2}`,
            );
        });

        it('a role\'s previous admins no longer revoke roles', async function () {
            await expect(
                adminInstance.revokeRole(ROLE_1, authorized.address)
            ).to.be.revertedWith(
                `BZAccessControl: account ${admin.toLowerCase()} is missing role ${ROLE_2}`,
            );
        });
    });

    describe('onlyRole modifier', function () {
        beforeEach(async function () {
            await adminInstance.grantRole(ROLE_1, authorized.address);
        });

        it('do not revert if sender has role', async function () {
            await adminInstance.connect(authorized).senderProtected(ROLE_1);
        });

        it('revert if sender doesn\'t have role #1', async function () {
            await expect(
                adminInstance.connect(other).senderProtected(ROLE_1)
            ).to.be.revertedWith(
                `AdminContract: account ${other.address.toLowerCase()} is missing role ${ROLE_1}`,
            );
        });

        it('revert if sender doesn\'t have role #2', async function () {
            await expect(
                adminInstance.connect(authorized).senderProtected(ROLE_2)
            ).to.be.revertedWith(
                `AdminContract: account ${authorized.address.toLowerCase()} is missing role ${ROLE_2}`,
            );
        });
    });

    describe('enumerating', function () {
        it('role bearers can be enumerated', async function () {
            await adminInstance.grantRole(ROLE_1, authorized.address);
            await adminInstance.grantRole(ROLE_1, other.address);
            await adminInstance.grantRole(ROLE_1, otherAuthorized.address);
            await adminInstance.revokeRole(ROLE_1, other.address);

            const memberCount = await adminInstance.getRoleCount(ROLE_1);
            expect(memberCount).to.equal('2');

            const bearers = [];
            for (let i = 0; i < memberCount; ++i) {
                bearers.push(await adminInstance.getRoleAt(ROLE_1, i));
            }

            expect(bearers).to.have.members([authorized.address, otherAuthorized.address]);
        });
        it('role enumeration should be in sync after renounceRole call', async function () {
            expect(await adminInstance.getRoleCount(ROLE_1)).to.equal('0');
            await adminInstance.grantRole(ROLE_1, admin);
            expect(await adminInstance.getRoleCount(ROLE_1)).to.equal('1');
            await adminInstance.renounceRole(ROLE_1, admin);
            expect(await adminInstance.getRoleCount(ROLE_1)).to.equal('0');
        });
    });
})

describe("Testing Inherit Contract", function () {
    // Creating the instance and contract info for the Admin Contract
    let inheritInstance, inheritContract;

    // Creating the users
    let admin, authorized, other, otherAdmin, otherAuthorized;

    beforeEach(async () => {
        // Getting the users provided by ethers
        [admin, authorized, other, otherAdmin, otherAuthorized] = await ethers.getSigners();

        // Getting the admin contract code (abi, bytecode, name)
        inheritContract = await ethers.getContractFactory("InheritContract");

        // Deploying the instance
        inheritInstance = await inheritContract.deploy();

        await inheritInstance.deployed();
    });

    describe('default admin', function () {
        it('deployer has default admin role', async function () {
            expect(await inheritInstance.hasRole(DEFAULT_ADMIN_ROLE, admin.address)).to.equal(true);
        });

        it('other roles\'s admin is the default admin role', async function () {
            expect(await inheritInstance.getRoleAdmin(ROLE_1)).to.equal(DEFAULT_ADMIN_ROLE);
        });

        it('default admin role\'s admin is itself', async function () {
            expect(await inheritInstance.getRoleAdmin(DEFAULT_ADMIN_ROLE)).to.equal(DEFAULT_ADMIN_ROLE);
        });
    });

    describe('granting', function () {
        beforeEach(async function () {
            await inheritInstance.grantRole(ROLE_1, authorized.address);
        });

        it('non-admin cannot grant role to other accounts', async function () {
            await expect(
                inheritInstance.connect(other).grantRole(ROLE_1, authorized.address)
            ).to.be.revertedWith(
                `BZAccessControl: account ${other.address.toLowerCase()} is missing role ${DEFAULT_ADMIN_ROLE}`,
            );
        });

        it('accounts can be granted a role multiple times', async function () {
            await inheritInstance.grantRole(ROLE_1, authorized.address);
            await expect(
                inheritInstance.grantRole(ROLE_1, authorized.address)
            ).not.to.be.emit(inheritInstance, 'RoleGranted');
        });
    });

    describe('revoking', function () {
        it('roles that are not had can be revoked', async function () {
            expect(await inheritInstance.hasRole(ROLE_1, authorized.address)).to.equal(false);

            await expect(
                inheritInstance.revokeRole(ROLE_1, authorized.address)
            ).not.to.be.emit(inheritInstance, 'RoleRevoked');
        });

        context('with granted role', function () {
            beforeEach(async function () {
                await inheritInstance.grantRole(ROLE_1, authorized.address);
            });

            it('admin can revoke role', async function () {
                await expect(
                    inheritInstance.revokeRole(ROLE_1, authorized.address)
                ).to.emit(inheritInstance, 'RoleRevoked').withArgs(ROLE_1, authorized.address, admin.address);

                expect(await inheritInstance.hasRole(ROLE_1, authorized.address)).to.equal(false);
            });

            it('non-admin cannot revoke role', async function () {
                await expect(
                    inheritInstance.connect(other).revokeRole(ROLE_1, authorized.address),
                ).to.be.revertedWith(
                    `BZAccessControl: account ${other.address.toLowerCase()} is missing role ${DEFAULT_ADMIN_ROLE}`,
                );
            });

            it('a role can be revoked multiple times', async function () {
                await inheritInstance.revokeRole(ROLE_1, authorized.address);

                await expect(
                    inheritInstance.revokeRole(ROLE_1, authorized.address)
                ).not.to.be.emit(inheritInstance, 'RoleRevoked');
            });
        });
    });

    describe('renouncing', function () {
        it('roles that are not had can be renounced', async function () {
            await expect(
                inheritInstance.connect(authorized).renounceRole(ROLE_1, authorized.address)
            ).to.be.revertedWith(
                `BZAccessControl: account ${authorized.address.toLowerCase()} is missing role ${ROLE_1}`,
            );
        });

        context('with granted role', function () {
            beforeEach(async function () {
                await inheritInstance.grantRole(ROLE_1, authorized.address);
            });

            it('bearer can renounce role', async function () {
                await expect(
                    inheritInstance.connect(authorized).renounceRole(ROLE_1, authorized.address)
                ).to.be.emit(inheritInstance, 'RoleRenounced').withArgs(ROLE_1, authorized.address);

                expect(await inheritInstance.hasRole(ROLE_1, authorized.address)).to.equal(false);
            });

            it('only the sender can renounce their roles', async function () {
                await expect(
                    inheritInstance.renounceRole(ROLE_1, authorized.address)
                ).to.be.revertedWith(
                    `BZAccessControl: account ${admin.address.toLowerCase()} is missing role ${ROLE_1}`,
                );
            });

            it('a role can be renounced multiple times', async function () {
                await inheritInstance.connect(authorized).renounceRole(ROLE_1, authorized.address);

                await expect(
                    inheritInstance.connect(authorized).renounceRole(ROLE_1, authorized.address)
                ).to.be.revertedWith(
                    `BZAccessControl: account ${authorized.address.toLowerCase()} is missing role ${ROLE_1}`,
                );
            });
        });
    });

    describe('setting role admin', function () {
        beforeEach(async function () {
            await expect(
                inheritInstance.setRoleAdmin(ROLE_1, ROLE_2)
            ).to.be.emit(inheritInstance, 'AdminRoleChanged').withArgs(ROLE_1, DEFAULT_ADMIN_ROLE, ROLE_2);

            await inheritInstance.grantRole(ROLE_2, otherAdmin.address);
        });

        it('a role\'s admin role can be changed', async function () {
            expect(await inheritInstance.getRoleAdmin(ROLE_1)).to.equal(ROLE_2);
        });

        it('the new admin can grant roles', async function () {
            await expect(
                inheritInstance.connect(otherAdmin).grantRole(ROLE_1, authorized.address)
            ).to.be.emit(inheritInstance, 'RoleGranted').withArgs(ROLE_1, authorized.address, otherAdmin.address);
        });

        it('the new admin can revoke roles', async function () {
            await inheritInstance.connect(otherAdmin).grantRole(ROLE_1, authorized.address);
            await expect(
                inheritInstance.connect(otherAdmin).revokeRole(ROLE_1, authorized.address)
            ).to.be.emit(inheritInstance, 'RoleRevoked').withArgs(ROLE_1, authorized.address, otherAdmin.address);
        });

        it('a role\'s previous admins no longer grant roles', async function () {
            await expect(
                inheritInstance.grantRole(ROLE_1, authorized.address),
            ).to.be.revertedWith(
                `BZAccessControl: account ${admin.address.toLowerCase()} is missing role ${ROLE_2}`,
            );
        });

        it('a role\'s previous admins no longer revoke roles', async function () {
            await expect(
                inheritInstance.revokeRole(ROLE_1, authorized.address)
            ).to.be.revertedWith(
                `BZAccessControl: account ${admin.address.toLowerCase()} is missing role ${ROLE_2}`,
            );
        });
    });

    describe('onlyRole modifier', function () {
        beforeEach(async function () {
            await inheritInstance.grantRole(ROLE_1, authorized.address);
        });

        it('do not revert if sender has role', async function () {
            await inheritInstance.connect(authorized).senderProtected(ROLE_1);
        });

        it('revert if sender doesn\'t have role #1', async function () {
            await expect(
                inheritInstance.connect(other).senderProtected(ROLE_1)
            ).to.be.revertedWith(
                `BZAccessControl: account ${other.address.toLowerCase()} is missing role ${ROLE_1}`,
            );
        });

        it('revert if sender doesn\'t have role #2', async function () {
            await expect(
                inheritInstance.connect(authorized).senderProtected(ROLE_2)
            ).to.be.revertedWith(
                `BZAccessControl: account ${authorized.address.toLowerCase()} is missing role ${ROLE_2}`,
            );
        });
    });

    describe('enumerating', function () {
        it('role bearers can be enumerated', async function () {
            await inheritInstance.grantRole(ROLE_1, authorized.address);
            await inheritInstance.grantRole(ROLE_1, other.address);
            await inheritInstance.grantRole(ROLE_1, otherAuthorized.address);
            await inheritInstance.revokeRole(ROLE_1, other.address);

            const memberCount = await inheritInstance.getRoleCount(ROLE_1);
            expect(memberCount).to.equal('2');

            const bearers = [];
            for (let i = 0; i < memberCount; ++i) {
                bearers.push(await inheritInstance.getRoleAt(ROLE_1, i));
            }

            expect(bearers).to.have.members([authorized.address, otherAuthorized.address]);
        });
        it('role enumeration should be in sync after renounceRole call', async function () {
            expect(await inheritInstance.getRoleCount(ROLE_1)).to.equal('0');
            await inheritInstance.grantRole(ROLE_1, admin.address);
            expect(await inheritInstance.getRoleCount(ROLE_1)).to.equal('1');
            await inheritInstance.renounceRole(ROLE_1, admin.address);
            expect(await inheritInstance.getRoleCount(ROLE_1)).to.equal('0');
        });
    });
})