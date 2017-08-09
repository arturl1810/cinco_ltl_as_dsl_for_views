package info.scce.pyro.sync;


import javax.ejb.Singleton;
import javax.websocket.Session;
import java.util.HashMap;
import java.util.Map;

/**
 * Author zweihoff
 */
@Singleton
public class UserRegistry extends WebSocketRegistry {
    /**
     * Map<UserId,Map<Websocket>>
     */
    private Map<Long, Session> currentOpenSockets;

    public UserRegistry(){
        currentOpenSockets = new HashMap<>();
    }

    public Map<Long, Session> getCurrentOpenSockets() {
        return currentOpenSockets;
    }

    public void setCurrentOpenSockets(Map<Long, Session> currentOpenSockets) {
        this.currentOpenSockets = currentOpenSockets;
    }

    public void send(long userId,WebSocketMessage message){
        if(currentOpenSockets.containsKey(userId)){
            super.send(currentOpenSockets.get(userId),message);
        }
    }
}
