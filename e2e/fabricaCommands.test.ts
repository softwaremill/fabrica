import TestCommands from "./TestCommands";
import { version as currentFabricaVersion } from "../package.json";

const commands = new TestCommands("e2e/__tmp__/commands-tests");

describe("init", () => {
  beforeEach(() => commands.cleanupWorkdir());

  it("should init simple fabrica config", () => {
    // When
    const commandResult = commands.fabricaExec("init");

    // Then
    expect(commandResult).toEqual(TestCommands.success());
    expect(commandResult.output).toContain("Sample config file created! :)");
    expect(commands.getFiles()).toEqual(["e2e/__tmp__/commands-tests/fabrica-config.json"]);
    expect(commands.getFileContent("fabrica-config.json")).toMatchSnapshot();
  });

  it("should init simple fabrica config with node chaincode", () => {
    // When
    const commandResult = commands.fabricaExec("init node");

    // Then
    expect(commandResult).toEqual(TestCommands.success());
    expect(commandResult.output).toContain("Sample config file created! :)");
    expect(commands.getFiles()).toEqual([
      "e2e/__tmp__/commands-tests/chaincodes/chaincode-kv-node/index.js",
      "e2e/__tmp__/commands-tests/chaincodes/chaincode-kv-node/package-lock.json",
      "e2e/__tmp__/commands-tests/chaincodes/chaincode-kv-node/package.json",
      "e2e/__tmp__/commands-tests/fabrica-config.json",
    ]);
    expect(commands.getFileContent("fabrica-config.json")).toMatchSnapshot();
  });
});

describe("use", () => {
  beforeEach(() => commands.cleanupWorkdir());

  it("should display versions", () => {
    // When
    const commandResult = commands.fabricaExec("use");

    // Then
    expect(commandResult).toEqual(TestCommands.success());
    expect(commandResult.output).toContain("0.0.1\n");
    expect(commandResult.output).toContain("0.1.0\n");
    expect(commands.getFiles()).toEqual([]);
  });
});

describe("validate", () => {
  beforeEach(() => commands.cleanupWorkdir());

  it("should validate default config", () => {
    // Given
    commands.fabricaExec("init");

    // When
    const commandResult = commands.fabricaExec("validate");

    // Then
    expect(commandResult).toEqual(TestCommands.success());
    expect(commandResult.output).toContain("Validation errors count: 0");
    expect(commandResult.output).toContain("Validation warnings count: 0");
    expect(commands.getFiles()).toContain("e2e/__tmp__/commands-tests/fabrica-config.json");
  });

  it("should validate custom config", () => {
    // Given
    const fabricaConfig = `${commands.relativeRoot}/samples/fabrica-config-hlf1.4-1org-1chaincode-raft.json`;

    // When
    const commandResult = commands.fabricaExec(`validate ${fabricaConfig}`);

    // Then
    expect(commandResult).toEqual(TestCommands.success());
    expect(commandResult.output).toContain("Validation errors count: 0");
    expect(commandResult.output).toContain("Validation warnings count: 1");
    expect(commands.getFiles()).toEqual([]);
  });

  it("should fail to validate if config file is missing", () => {
    const commandResult = commands.fabricaExec("validate");

    // Then
    expect(commandResult).toEqual(TestCommands.failure());
    expect(commandResult.output).toContain("commands-tests/fabrica-config.json does not exist\n");
    expect(commands.getFiles()).toEqual([]);
  });
});

describe("extend config", () => {
  beforeEach(() => commands.cleanupWorkdir());

  it("should extend default config", () => {
    // Given
    commands.fabricaExec("init");

    // When
    const commandResult = commands.fabricaExec("extend-config", true);

    // Then
    expect(commandResult).toEqual(TestCommands.success());

    const cleanedOutput = commandResult.output
      .replace(/"fabricaConfig": "(.*?)"/g, '"fabricaConfig": "<absolute path>"')
      .replace(/"chaincodesBaseDir": "(.*?)"/g, '"chaincodesBaseDir": "<absolute path>"');
    expect(cleanedOutput).toMatchSnapshot();
  });

  it("should extend custom config", () => {
    // Given
    const fabricaConfig = `${commands.relativeRoot}/samples/fabrica-config-hlf2-2orgs-2chaincodes-raft.yaml`;

    // When
    const commandResult = commands.fabricaExec(`extend-config ${fabricaConfig}`, true);

    // Then
    expect(commandResult).toEqual(TestCommands.success());
    const cleanedOutput = commandResult.output
      .replace(/"fabricaConfig": "(.*?)"/g, '"fabricaConfig": "<absolute path>"')
      .replace(/"chaincodesBaseDir": "(.*?)"/g, '"chaincodesBaseDir": "<absolute path>"');
    expect(cleanedOutput).toMatchSnapshot();
  });

  it("should fail to extend if config file is missing", () => {
    const commandResult = commands.fabricaExec("extend-config", true);

    // Then
    expect(commandResult).toEqual(TestCommands.failure());
    expect(commandResult.output).toContain("commands-tests/fabrica-config.json does not exist\n");
  });
});

describe("version", () => {
  it("should print version information", () => {
    // When
    const commandResult = commands.fabricaExec("version");

    // Then
    expect(commandResult).toEqual(TestCommands.success());
    expect(commandResult.outputJson()).toEqual(
      expect.objectContaining({
        version: currentFabricaVersion,
        build: expect.stringMatching(/.*/),
      }),
    );
  });

  it("should print verbose version information", () => {
    // When
    const commandResult1 = commands.fabricaExec("version -v");
    const commandResult2 = commands.fabricaExec("version --verbose");

    // Then
    expect(commandResult1).toEqual(TestCommands.success());
    expect(commandResult1.outputJson()).toEqual(
      expect.objectContaining({
        version: currentFabricaVersion,
        build: expect.stringMatching(/.*/),
        supported: expect.objectContaining({
          fabricaVersions: expect.stringMatching(/.*/),
          hyperledgerFabricVersions: expect.anything(),
        }),
      }),
    );

    expect(commandResult1.status).toEqual(commandResult2.status);
    expect(commandResult1.output).toEqual(commandResult2.output);
  });
});
