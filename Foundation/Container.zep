namespace Raichu\Foundation;

class Container implements \ArrayAccess
{
    protected bindings = [];
    protected instances = [];
    protected data = [];

    public function bind(string name, concrete, boolean shared = false)
    {
        unset(this->instances[name]);

        if is_null(concrete) {
            let concrete = name;
        }

        let this->bindings[name] = ["concrete": concrete, "shared": shared];
    }

    public function singleton(string name, concrete)
    {
        this->bind(name, concrete, true);
    }

    public function make(string name, array parameters = [])
    {
        if isset this->instances[name] {
            return this->instances[name];
        }

        var concrete;
        if isset this->bindings[name] {
            let concrete = this->bindings[name]["concrete"];
        } else {
            let concrete = name;
        }
        var instance = this->build(concrete, parameters);
        if instance === false {
            return null;
        }

        if isset this->bindings[name] && this->bindings[name]["shared"] {
            let this->instances[name] = instance;
        }

        return instance;
    }

    public function build(concrete, array parameters = [])
    {
        if (concrete instanceof \Closure) {
            return {concrete}(this, parameters);
        }

        var e;
        try {
            var reflector, constructor;
            let reflector = new \ReflectionClass(concrete),
                constructor = reflector->getConstructor();
            if is_null(constructor) {
                return new {concrete}();
            }

            return reflector->newInstanceArgs(array_merge([this], parameters));
        } catch \Exception, e {
            return e->getMessage();
        }
    }

    public function instance(string name, instance)
    {
        let this->instances[name] = instance;
    }

    public function unbind(string name = "")
    {
        if name == "" {
            let this->bindings = [];
        } else {
            unset(this->bindings[name]);
        }
    }

    public function forgetInstance(string name = "")
    {
        if name == "" {
            let this->instances = [];
        } else {
            unset(this->instances[name]);
        }
    }

    public function flush()
    {
        let this->bindings = [], this->instances = [];
    }

    public function offsetExists(key)
    {
        return isset this->data[key];
    }

    public function offsetGet(key)
    {
        return this->data[key];
    }

    public function offsetSet(key, value)
    {
        let this->data[key] = value;
    }

    public function offsetUnset(key)
    {
        unset(this->data[key]);
    }

    public function __get(key)
    {
        return this->offsetGet(key);
    }

    public function __set(key, value)
    {
        this->offsetSet(key, value);
    }

    public function __unset(key)
    {
        this->offsetUnset(key);
    }

    public function __isset(key)
    {
        return this->offsetExists(key);
    }
}
