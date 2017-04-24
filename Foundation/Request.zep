namespace Raichu\Foundation;

class Request
{
    protected headers;
    protected path;
    protected method;

    public function getHeader()
    {
        if this->headers === null {
            var name, value, headers = [], short_name;
            for name, value in _SERVER {
                if substr(name, 0, 5) == "HTTP_" || name == "CONTENT_TYPE" || name == "CONTENT_LENGTH" {
                    let short_name = str_replace([" ", "Http"], ["-", "HTTP"], ucwords(strtolower(str_replace("_", " ", substr(name, 5)))));
                    let headers[short_name] = value;
                }
            }
            let this->headers = headers;
        }
        return this->headers;
    }

    public function getPath()
    {
        if this->path === null {
            var basepath, path;
            let basepath = implode("/", array_slice(explode("/", _SERVER["SCRIPT_NAME"]), 0, -1))."/";
            let path = substr(_SERVER["REQUEST_URI"], strlen(basepath));

            if strstr(path, "?") > 0 {
                let path = substr(path, 0, strpos(path, "?"));
            }

            let this->path = "/".trim(path, "/");
        }

        return this->path;
    }

    public function getMethod()
    {
        if this->method === null {
            var method;
            let method = _SERVER["REQUEST_METHOD"];
            if method == "HEAD" {
                ob_start();
                let method = "GET";
            }
            if method == "POST" {
                var headers;
                let headers = this->getHeader();

                if isset headers["X-HTTP-Method-Override"] && in_array(headers["X-HTTP-Method-Override"], ["PUT", "DELETE", "PATCH"]) {
                    let method = headers["X-HTTP-Method-Override"];
                }
            }
            let this->method = method;
        }

        return this->method;
    }
}
