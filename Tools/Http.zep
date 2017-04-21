namespace Raichu\Tools;

class Http
{
    protected api_path = "";
    protected url = "";
    protected headers = [];
    protected withHeader = false;
    protected info = [];
    protected error = null;
    protected opts = [
        "dns_use_global_cache" : true,
        "dns_cache_timeout" : 300,
        "returntransfer" : true,
        "failonerror" : true,
        "maxredirs" : 5,
        "connecttimeout" : 4,
        "timeout" : 8
    ];

    protected function getHandler(opts = [])
    {
        var ch;
        let ch = curl_init();
        let opts = array_merge(this->opts, opts);
        curl_setopt(ch, CURLOPT_DNS_USE_GLOBAL_CACHE, opts["dns_use_global_cache"]);
        curl_setopt(ch, CURLOPT_DNS_CACHE_TIMEOUT, opts["dns_cache_timeout"]);
        curl_setopt(ch, CURLOPT_RETURNTRANSFER, opts["returntransfer"]);
        curl_setopt(ch, CURLOPT_FAILONERROR, opts["failonerror"]);
        curl_setopt(ch, CURLOPT_MAXREDIRS, opts["maxredirs"]);
        curl_setopt(ch, CURLOPT_CONNECTTIMEOUT, opts["connecttimeout"]);
        curl_setopt(ch, CURLOPT_TIMEOUT, opts["timeout"]);

        return ch;
    }

    public function setPath(api_path)
    {
        let this->api_path = api_path;

        return this;
    }

    public function setHost(host)
    {
        let this->headers[] = "Host: ".host;

        return this;
    }

    public function setHeader(header)
    {
        let this->headers[] = header;

        return this;
    }

    public function getHeader()
    {
        return this->headers;
    }

    public function withHeader()
    {
        let this->withHeader = true;

        return this;
    }

    public function Get(api, query = null, opts = [])
    {
        var ch;
        let ch = this->getHandler(opts),
            this->url = this->api_path.api.query;
        if !empty query {
            let query = is_array(query) ? http_build_query(query, "", "&", PHP_QUERY_RFC3986) : query; // PHP_QUERY_RFC3986 : Space will be turn to %20
            let this->url .= "?".query;
        }
        if !empty this->headers {
            curl_setopt(ch, CURLOPT_HTTPHEADER, this->headers);
        }

        return this->run(ch);
    }

    public function Post(api, query = null, opts = [])
    {
        var ch;
        let ch = this->getHandler(opts),
            this->url = this->api_path.api;
        curl_setopt(ch, CURLOPT_POST, 1);
        if query != null {
            let query = is_array(query) ? http_build_query(query) : query;
            curl_setopt(ch, CURLOPT_POSTFIELDS, query);
        }
        if !empty this->headers {
            curl_setopt(ch, CURLOPT_HTTPHEADER, this->headers);
        }

        return this->run(ch);
    }

    public function Put(api, file = null, query = null, opts = [])
    {
        var ch;
        let ch = this->getHandler(opts),
            this->url = this->api_path.api;
        if !empty query {
            let query = is_array(query) ? http_build_query(query) : query;
            let this->url .= "?".query;
        }

        if file {
            var fp = null;
            if is_array(file) {
                let this->headers[] = "Content-Type: ".file["filetype"];
                if isset file["filepath"] {
                    let fp = fopen(file["filepath"], "r");
                } elseif isset file["fp"] {
                    let fp = file["fp"];
                }
            }
            if is_string(file) {
                let fp = fopen(file, "r");
                var img_info;
                let img_info = getimagesize(file);
                if img_info {
                    let this->headers[] = "Content-Type: ".img_info["mime"];
                }
            }
            curl_setopt(ch, CURLOPT_PUT, 1);
            curl_setopt(ch, CURLOPT_INFILE, fp);
        }
        if !empty this->headers {
            curl_setopt(ch, CURLOPT_HTTPHEADER, this->headers);
        }

        return this->run(ch);
    }

    protected function run(ch)
    {
        curl_setopt(ch, CURLOPT_URL, this->url);
        if this->withHeader {
            curl_setopt(ch, CURLOPT_HEADER, 1);
        }

        var response;
        let response = curl_exec(ch);
        if response === false {
            let this->error = [
                "errno" : curl_errno(ch),
                "error" : curl_error(ch)
            ];
        } else {
            let this->info = curl_getinfo(ch);
        }
        curl_close(ch);

        return response;
    }

    public function info()
    {
        return this->info;
    }

    public function error()
    {
        return this->error;
    }
}
