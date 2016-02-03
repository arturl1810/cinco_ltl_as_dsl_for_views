package de.ls5.cinco.pyro.parser;

import de.ls5.dywa.generated.entity.Point;
import org.json.simple.JSONObject;

/**
 * Created by zweihoff on 24.06.15.
 */
public class PointParser {

    public static JSONObject toJSON(Point point){
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("x",new Long(point.getx()));
        jsonObject.put("y",new Long(point.gety()));
        return jsonObject;
    }
}
