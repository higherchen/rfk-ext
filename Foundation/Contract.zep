namespace Raichu\Foundation;

class Contract
{
    protected app;
    protected autoload = [];
    protected singleton = [];

    public function __construct(app)
    {
        let this->app = app;
        if !empty this->autoload {
            var name, classname;
            for name, classname in this->autoload {
                this->app->bind(name, classname);
            }
        }
        if !empty this->singleton {
            var name, classname;
            for name, classname in this->singleton {
                this->app->singleton(name, classname);
            }
        }
    }

    public function make(string name, array parameters = [])
    {
        return this->app->make(name, parameters);
    }
}
