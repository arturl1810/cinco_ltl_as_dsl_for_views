package info.scce.pyro.sync;


import javax.ejb.Singleton;
import javax.ejb.Startup;
import javax.websocket.Session;
import java.util.HashMap;
import java.util.Map;

/**
 * Author zweihoff
 */
@Singleton
public class ProjectRegistry extends WebSocketRegistry {
    /**
     * Map<ProjectId,Map<UserId,Session>>
     */
    private final Map<Long, Map<Long,Session>> currentOpenSockets;

    public ProjectRegistry(){
        currentOpenSockets = new HashMap<>();
    }

    public Map<Long, Map<Long,Session>> getCurrentOpenSockets() {
        return currentOpenSockets;
    }


    public void send(long projectId,WebSocketMessage message){
        if(currentOpenSockets.containsKey(projectId)){
            currentOpenSockets.get(projectId).entrySet().forEach(n->super.send(n.getValue(),message));
        }
    }
}
