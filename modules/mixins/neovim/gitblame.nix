{
    programs.nixvim.plugins.gitblame = {
        enable = true;
        delay = 3000;
        dateFormat = "%r";
        messageTemplate = "<author>, <date>";
    };
}
