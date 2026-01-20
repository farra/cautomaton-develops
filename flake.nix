{
  description = "Nix develop + deps.toml project template";

  outputs = { self, ... }: {
    templates = {
      default = {
        description = "Development environment with deps.toml and tool bundles";
        path = ./template;
      };
    };
  };
}
