package info.scce.pyro.sync;

import de.ls5.dywa.generated.controller.info.scce.pyro.core.PyroUserController;

import javax.ejb.Startup;
import javax.ejb.Stateless;
import javax.inject.Inject;
import javax.inject.Named;
import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Stream;

/**
 * Author zweihoff
 */
@ServerEndpoint(value = "/ws/graphmodel/{graphModelId}/private")
@Named
@Startup
@Stateless
public class GraphModelWebSocket {

    @Inject
    PyroUserController subjectController;

    @Inject
    GraphModelRegistry graphModelRegistry;

    private static final Logger LOGGER =
            Logger.getLogger(GraphModelWebSocket.class.getName());

    @OnOpen
    public void open(@PathParam("graphModelId") long graphModelId, final Session session, EndpointConfig conf) throws IOException {
        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser user = subjectController
                .read(Long.parseLong(session.getUserPrincipal().getName()));
        if(user!=null){
            graphModelRegistry.getCurrentOpenSockets().putIfAbsent(graphModelId,new HashMap<>());
            graphModelRegistry.getCurrentOpenSockets().get(graphModelId).put(user.getDywaId(),session);
        } else {
            session.close();
        }
    }

    public void send(long projectId,WebSocketMessage message)
    {
        graphModelRegistry.send(projectId,message);
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        LOGGER.log(Level.INFO, "New message from Client [{0}]: {1}",
                new Object[] {session.getId(), message});
    }

    @OnClose
    public void onClose(Session session) {
        long userId = Long.parseLong(session.getUserPrincipal().getName());
        this.graphModelRegistry.getCurrentOpenSockets().values().removeIf(n->n.containsKey(userId));
        LOGGER.log(Level.INFO, "Close graphmodel connection for client: {0}",
                session.getId());
    }

    @OnError
    public void onError(Throwable exception, Session session) {
        LOGGER.log(Level.INFO, "Error for graphmodel client: {0}", session.getId());
    }

    public boolean hasGraphModel(long graphModelDywaId)
    {
        return 	this.graphModelRegistry.getCurrentOpenSockets().containsKey(graphModelDywaId)
                && this.graphModelRegistry.getCurrentOpenSockets().get(graphModelDywaId).size() > 0;
    }

    /**
     * Closes connections of all WebSockets, that are
     * listening on currentUser with the given id,
     * because of the deletion.
     *
     * @param dywaId	ID of graphModel.
     */
    public void closeAfterDeletion(long dywaId)
    {
        if(this.hasGraphModel(dywaId))
        {
            this.graphModelRegistry.getCurrentOpenSockets()
                    .get(dywaId).values()
                    .forEach((w) -> {
                        try {
                            System.out.println("[PYRO] Closing WebSocket with code 4000 after deleting project" + dywaId + ".");
                            graphModelRegistry.close(w,4000);
                        } catch(Exception e) {
                            e.printStackTrace();
                        }
                    });
            this.graphModelRegistry.getCurrentOpenSockets().remove(dywaId);
        }
    }

    /**
     * Closes all open sockets to users, not contained in the allowedUsersList
     * for the given project
     * @param graphModelDywaId ID of the project
     * @param allowedUserList IDs of the allowed users for the project
     */
    public void updateUserList(long graphModelDywaId, List<Long> allowedUserList){
        if(this.hasGraphModel(graphModelDywaId))
        {
            Stream<Map.Entry<Long, Session>> socketsToClose = this.graphModelRegistry.getCurrentOpenSockets()
                    .get(graphModelDywaId).entrySet().stream().filter(n->!allowedUserList.contains(n.getKey()));
            socketsToClose
                    .forEach((w) -> {
                        try {
                            System.out.println("[PYRO] Closing WebSocket with code 4000 after deleting user from allowed list.");
                            graphModelRegistry.close(w.getValue(),4001);
                        } catch(Exception e) {
                            e.printStackTrace();
                        }
                        this.graphModelRegistry.getCurrentOpenSockets().get(graphModelDywaId).remove(w);
                    });

        }
    }



}
