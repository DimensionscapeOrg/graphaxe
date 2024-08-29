package ghx._internal.macro;
import haxe.macro.ComplexTypeTools;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;

class ConfigMacro {
   macro public static function build():Array<Field> {
        // Path to your config.json in the project root
        var filePath:String = FileSystem.fullPath('./config.json');

        // Read and parse the JSON file
        var jsonData:String = File.getContent(filePath);
        var configData:Dynamic = Json.parse(jsonData);       

        var version = {
            name: "version",
            access: [Access.APublic, Access.AStatic, Access.AInline, Access.AFinal],
            kind: FieldType.FVar(null, macro $v{"0.0.2"}),
            pos: Context.currentPos()
        }

        var fields:Array<Field> = [version];
       
        for (key in Reflect.fields(configData)) {
            var value = Reflect.field(configData, key);

            fields.push({
                name: key,
                access: [Access.APublic, Access.AStatic, Access.AFinal],
                kind: FieldType.FVar(null, macro $v{value}),
                pos: Context.currentPos()
            });
        }

        return fields;
    }
}
#end