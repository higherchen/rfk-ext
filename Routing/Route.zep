namespace Raichu\Routing;

class Route
{
    protected options = [
        "alias" : false,
        "pattern" : "",
        "methods" : [],
        "handler" : null,
        "middleware" : []
    ];
    protected matches = [];

    public function __construct(pattern, handler)
    {
        let this->options["pattern"] = pattern, this->options["handler"] = handler;
    }

    public function alias(name)
    {
        let this->options["alias"] = name;

        return this;
    }

    public function method(array methods)
    {
        let this->options["methods"] = array_map("strtoupper", methods);

        return this;
    }

    public function middleware(concrete)
    {
        let this->options["middleware"] = concrete;

        return this;
    }

    public function match(request)
    {
        var route, pattern, path, method, matches;
        let route = this->options,
            pattern = route["pattern"],
            path = request->getPath(),
            method = request->getMethod();

        if !empty route["methods"] && !in_array(method, route["methods"]) {
            return false;
        }

        if preg_match_all("#^".pattern."$#", path, matches, PREG_OFFSET_CAPTURE) {
            let matches = array_slice(matches, 1),
                this->matches = matches;

            var params;
            let params = array_map([this, "buildParams"], matches, array_keys(matches)
            );

            if (route["middleware"]) {
                try {
                    var middleware = route["middleware"];
                    if is_string(middleware) {
                        if strpos(middleware, "@") > 0 {
                            var exp, classname, action, obj;
                            let exp = explode("@", middleware),
                                classname = exp[0],
                                action = exp[1];
                            let obj = new {classname}();
                            obj->{action}(params);
                        }
                        if strpos(middleware, "::") > 0 {
                            var exp, classname, action;
                            let exp = explode("::", middleware),
                                classname = exp[0],
                                action = exp[1];
                            {classname}::{action}(params);
                        }
                    }
                    if middleware instanceof \Closure {
                        call_user_func_array(middleware, params);
                    }
                } catch \Exception {
                    return false;
                }
            }

            if route["handler"] instanceof \Closure {
                call_user_func_array(route["handler"], params);
                return true;
            }

            if is_string(route["handler"]) && strpos(route["handler"], "@") > 0 {
                var exp;
                let exp = explode("@", route["handler"]);
                return [exp[0], exp[1], params];
            }
        }

        return false;
    }

    protected function buildParams(match, index) {
        var next, matches = this->matches;
        let next = index + 1;
        if isset matches[next] && isset matches[next][0] && is_array(matches[next][0]) {
            return trim(substr(match[0][0], 0, matches[next][0][1] - match[0][1]), "/");
        } else {
            return isset match[0][0] ? trim(match[0][0], "/") : null;
        }
    }
}