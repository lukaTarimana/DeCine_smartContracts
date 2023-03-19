module.exports = {
  plugins: [require("prettier-plugin-solidity")],
  overrides: [
    {
      files: "*.sol",
      options: {
        printWidth: 120,
        tabWidth: 4,
        useTabs: false,
        singleQuote: false,
        bracketSpacing: true
      }
    },
    {
      files: "*.js",
      options: {
        trailingComma: "none"
      }
    }
  ]
}