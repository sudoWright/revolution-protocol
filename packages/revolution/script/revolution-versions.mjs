import fs from "fs";
import path from "path";
import { promisify } from "util";
import { fileURLToPath } from "url";

const readFileAsync = promisify(fs.readFile);
const writeFileAsync = promisify(fs.writeFile);

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const makePackageVersionFile = async (version) => {
  console.log("updating contract version to ", version);
  // read the version from the root package.json:

  const packageVersionCode = `// This file is automatically generated by code; do not manually update
// Last updated on ${new Date().toISOString()}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.22;

import { IVersionedContract } from "@cobuild/utility-contracts/src/interfaces/IVersionedContract.sol";


/// @title RevolutionVersion
/// @notice Base contract for versioning contracts
contract RevolutionVersion is IVersionedContract {
    /// @notice The version of the contract
    function contractVersion() external pure override returns (string memory) {
        return "${version}";
    }
}
`;

  // write the file to __dirname__/../src/version/RevolutionVersion.sol:
  const filePath = path.join(
    __dirname,
    "..",
    "src",
    "version",
    "RevolutionVersion.sol"
  );

  console.log("generated contract version code:", packageVersionCode);
  console.log("writing file to", filePath);

  await writeFileAsync(filePath, packageVersionCode);
};

const getVersion = async () => {
  // read package.json file, parse json, then get version:
  const packageJson = JSON.parse(
    await readFileAsync(path.join(__dirname, "..", "package.json"))
  );

  return packageJson.version;
};

const main = async () => {
  const version = await getVersion();
  await makePackageVersionFile(version);
};

main();
