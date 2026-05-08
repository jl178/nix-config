{
  programs.nixvim.plugins.gitlinker = {
    enable = true;
    settings.callbacks = {
      "github.com".__raw = "require('gitlinker.hosts').get_github_type_url";
      "git.seriouscompany.com".__raw = "require('gitlinker.hosts').get_github_type_url";
      "gitlab.com".__raw = "require('gitlinker.hosts').get_gitlab_type_url";
      "git.cs.du.edu".__raw = "require('gitlinker.hosts').get_gitlab_type_url";
    };
  };
}
