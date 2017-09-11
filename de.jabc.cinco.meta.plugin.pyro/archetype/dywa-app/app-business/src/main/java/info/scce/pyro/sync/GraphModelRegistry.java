package info.scce.pyro.sync;


import javax.ejb.Singleton;
import javax.websocket.Session;
import java.util.HashMap;
import java.util.Map;

/**
 * Author zweihoff
 */
@Singleton
public class GraphModelRegistry extends WebSocketRegistry {
    /**
     * Map<GraphModel,Map<UserId,Session>>
     */
    private final Map<Long, Map<Long,Session>> currentOpenSockets;

    public GraphModelRegistry(){
        currentOpenSockets = new HashMap<>();
    }

    public Map<Long, Map<Long,Session>> getCurrentOpenSockets() {
        return currentOpenSockets;
    }


    public void send(long graphModelId,WebSocketMessage message){
        if(currentOpenSockets.containsKey(graphModelId)){
            currentOpenSockets.get(graphModelId).entrySet().forEach(n->super.send(n.getValue(),message));
        }
    }
}
