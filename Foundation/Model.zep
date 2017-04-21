namespace Raichu\Foundation;

abstract class Model
{
    protected static db = [];
    protected database = "default";
    protected table = "";
    protected pk = "id";
    protected prepared = [];
    protected insert_sql = "";
    protected update_sql = "";

    public function __construct(app)
    {
        if !isset Model::db[this->database] {
            var config, db_config;
            let config = app->loadConfig("database");
            let db_config = config[this->database];
            let Model::db[this->database] = new \PDO(
                db_config["connection_string"],
                db_config["username"],
                db_config["password"],
                [
                    \PDO::MYSQL_ATTR_INIT_COMMAND: "SET NAMES utf8",
                    \PDO::ATTR_PERSISTENT: true
                ]
            );
        }
        if empty this->table {
            var ref, name;
            let ref = new \ReflectionClass(get_class(this));
            let name = ref->getShortName();
            let this->table = lcfirst(str_replace("Model", "", name));
        }
    }

    public function getConn()
    {
        return Model::db[this->database];
    }

    public function add(data)
    {
        if this->insert_sql !== "" {
            var stmt, cnt;
            let stmt = this->getStatement(this->insert_sql);
            stmt->execute(data);
            let cnt = stmt->rowCount();

            return cnt ? this->getConn()->lastInsertId() : cnt;
        }
    }

    public function update(data)
    {
        if this->update_sql !== "" {
            var stmt;
            let stmt = this->getStatement(this->update_sql);
            stmt->execute(data);

            return stmt->rowCount();
        }
    }

    public function find_one(id)
    {
        var sql, stmt, rows;
        let sql = "SELECT * FROM ".this->table." WHERE ".this->pk."=?";
        let stmt = this->getStatement(sql);
        stmt->execute([id]);
        let rows = stmt->fetchAll();

        return rows[0];
    }

    public function remove(id)
    {
        var sql, stmt;
        let sql = "DELETE FROM ".this->table." WHERE ".this->pk."=?";
        let stmt = this->getStatement(sql);
        stmt->execute([id]);

        return stmt->rowCount();
    }

    public function getStatement(sql)
    {
        var mark;
        let mark = md5(sql);
        if !isset this->prepared[mark] {
            let this->prepared[mark] = this->getConn()->prepare(sql);
        }

        return this->prepared[mark];
    }

    public function __call(method, arguments)
    {
        if !empty Model::db[this->database] && method_exists(Model::db[this->database], method) {
            return call_user_func_array([Model::db[this->database], method], arguments);
        }

        return false;
    }
}
