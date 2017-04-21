namespace Raichu\Foundation;

class App extends Container
{
    protected base_dir;
    protected config_dir;
    protected module_enabled = [];

    public function __construct(string basedir)
    {
        let this->base_dir = basedir, this->config_dir = this->base_dir."/Config";

        var user_loader;
        let user_loader = new Loader(basedir);
        spl_autoload_register([user_loader, "autoload"]);

        this->singleton("request", "\\Raichu\\Foundation\\Request");
        this->singleton("response", "\\Raichu\\Foundation\\Response");
    }

    public function loadConfig(key)
    {
        if !isset this->{key} {
            let this->{key} = parse_ini_file(this->config_dir."/".key.".ini", true);
        }

        return this->{key};
    }

    public function dispatch(string prefix, string name)
    {
        let this->module_enabled[prefix] = ucfirst(name);
    }

    public function getCurrentRoute() {
        var request;
        let request = this->make("request");

        var path = request->getPath();
        if !empty this->module_enabled {
            var prefix, module_name;
            for prefix, module_name in this->module_enabled {
                if strpos(path, prefix) === 0 {
                    return this->base_dir."/Modules/".module_name."/router.php";
                }
            }
        }

        return this->base_dir."/router.php";
    }

    public function handle(router)
    {
        var request, response;
        let request = this->make("request"),
            response = this->make("response");

        var resolved = router->handle(request);
        if resolved === false {
            response->abort(404);
        }
        if is_array(resolved) {
            var controller = resolved[0], action = resolved[1], parameters = resolved[2];
            if !class_exists(controller) {
                response->abort(404);
            }

            var obj;
            let obj = new {controller}(this);
            if (!method_exists(obj, action)) {
                response->abort(404);
            }

            call_user_func_array([obj, action], parameters);
            response->response();
        }
    }
}
