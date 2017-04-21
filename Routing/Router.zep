namespace Raichu\Routing;

class Router
{
    protected prefix = "";
    protected rule;
    protected routes = [];
    protected module = "";

    public function prefix(prefix, module = "")
    {
        let this->prefix = prefix;
        if module != "" {
            let this->module = ucfirst(module);
        }
    }

    public function match(pattern, handler)
    {
        if this->prefix != "" {
            let pattern = this->prefix.pattern;
        }
        
        let handler = is_string(handler) ? this->module."\\Controllers\\".handler : handler;

        var route;
        let route = new Route(pattern, handler);
        let this->routes[] = route;

        return route;
    }

    public function setDefault(rule)
    {
        let this->rule = rule;

        return this;
    }

    public function handle(request)
    {
        var resolved;

        if !empty this->routes {
            var route;
            for route in this->routes {
                let resolved = route->match(request);
                if resolved !== false {
                    return resolved;
                }
            }
        }

        if this->rule !== null && is_callable(this->rule) {
            let resolved = call_user_func(this->rule, request);
            return resolved;
        } else {
            var path, exp, name, action, params = [], cnt, prefix = this->prefix;
            let path = request->getPath();
            if prefix != "" && strpos(path, prefix) === 0 {
                let path = substr(path, strlen(prefix));
            }

            let path = trim(path, "/");
            let exp = path != "" ? explode("/", trim(path, "/")) : [];

            let name = "index", action = "index", cnt = count(exp);
            if cnt == 1 {
                let name = exp[0];
            }
            if cnt > 1 {
                let name = exp[0], action = exp[1];
                if (is_numeric(action)) {
                    let params[] = action, action = "handle";
                }
            }

            return [
                this->module."\\Controllers\\".ucfirst(name)."Controller",
                action,
                params
            ];
        }

        return false;
    }
}
