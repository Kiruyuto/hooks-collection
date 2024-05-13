# hooks-collection
Collection of Git Hooks I usually use ¯\\_(ツ)_/¯

## Short description of each hook
- [pre-commit](./pre-commit): Runs dotnet format on staged .CS files. Uses `info` severity for maximum formatting.
- [commit-msg](./commit-msg): Checks if the commit message follows the pattern: `type(scope): message`. Where `type` is one of the following: `feat`, `fix`, `ci`, `chore`, `docs`, `test`, `style`, `refactor`, `revert`, `build`, `release`, `security`. `scope` is optional and `message` is a short description of the commit. Does not check for the length of the commit message.  
  TL;DR: Enforces [Conventional Commits](https://www.conventionalcommits.org/en) format.