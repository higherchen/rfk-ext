namespace Raichu\Foundation;

class Loader
{
    protected basedir;

    public function __construct(string basedir = ".")
    {
        let this->basedir = basedir->trimright("/");
    }

    public function autoload(string classname)
    {
        var path, block;
        let path = this->basedir,
            classname = trim(classname, "\\"),
            block = explode("\\", classname);

        if !in_array(block[0], ["Controllers", "Models", "Services"]) {
            let path .= "/Modules";
        }

        var truename = array_pop(block);
        if !empty block {
            let path .= "/".implode("/", block);
        }
        require path."/".truename.".php";
    }
}