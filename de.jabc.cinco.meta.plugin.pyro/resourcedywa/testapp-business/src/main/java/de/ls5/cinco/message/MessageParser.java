package de.ls5.cinco.message;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

/**
 * Created by zweihoff on 09.07.15.
 */
public class MessageParser {
    public static JSONObject parse(String jsonString)
    {
        JSONParser parser = new JSONParser();
        try {
            Object object = parser.parse(jsonString);
            return (JSONObject) object;
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return null;
    }
}
