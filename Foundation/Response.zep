namespace Raichu\Foundation;

class Response
{
    protected ret = [];
    public error_http_code = [
        404: "Not Found",
        405: "Method Not Allowed",
        500: "Internal Server Error",
        502: "Bad Gateway or Proxy Error",
        503: "Service Unavailable",
        504: "Gateway Time-out"
    ];

    public function __set(name, value)
    {
        let this->ret[name] = value;
    }

    public function __get(name)
    {
        return this->ret[name];
    }

    public function abort(code, message = "", format = "")
    {
        var accept_code = [404, 405, 500, 502, 503, 504];
        if !in_array(code, accept_code) {
            let code = 500;
        }
        if message == "" {
            let message = code." ".this->error_http_code[code];
        }
        if format == "json" {
            this->json(["code": code, "data": message]);
        } else {
            header(_SERVER["SERVER_PROTOCOL"]." ".message);
            exit(message);
        }
    }

    public function json(data)
    {
        header("Content-Type:application/json; charset=utf-8");
        exit(json_encode(data));
    }

    public function response()
    {
        if !empty this->ret {
            this->json(this->ret);
        }
    }
}
