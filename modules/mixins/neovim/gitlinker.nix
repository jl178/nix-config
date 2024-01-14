{
  programs.nixvim.plugins.gitlinker = {
    enable = true;
    callbacks = {
      "github.com" = "get_github_type_url";
      "git.seriouscompany.com" = "get_github_type_url";
      "gitlab.com" = "get_gitlab_type_url";
      "git.cs.du.edu" = "get_gitlab_type_url";
    };
  };
}
