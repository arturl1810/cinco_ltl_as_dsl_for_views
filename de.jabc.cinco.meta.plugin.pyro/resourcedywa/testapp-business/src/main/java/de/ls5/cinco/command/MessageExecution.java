package de.ls5.cinco.command;

import de.ls5.cinco.message.MessageParser;
import org.json.simple.JSONObject;

/**
 * Created by zweihoff on 16.06.15.
 */
public class MessageExecution {
    public static void executeCreateMessage(String message) {
        JSONObject jsonObject = MessageParser.parse(message);

    }

    public static void executeEditMessage(String message) {

    }

    public static void executeRemoveMessage(String message) {

    }
}
