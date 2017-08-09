package info.scce.pyro.sync;

import de.ls5.dywa.generated.controller.info.scce.pyro.core.PyroUserController;

import javax.ejb.Startup;
import javax.ejb.Stateless;
import javax.inject.Inject;
import javax.inject.Named;
import javax.transaction.Transactional;
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
@ServerEndpoint(value = "/ws/project/{projectId}/private")
@Named
@Startup
@Transactional
@Stateless
public class ProjectWebSocket {

    @Inject
    PyroUserController subjectController;

    @Inject
    ProjectRegistry projectRegistry;

    private static final Logger LOGGER =
            Logger.getLogger(ProjectWebSocket.class.getName());

    @OnOpen
    public void open(@PathParam("projectId") long clientId, final Session session, EndpointConfig conf) throws IOException {
        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser user = subjectController
                .read(Long.parseLong(session.getUserPrincipal().getName()));
        if(user!=null){
            projectRegistry.getCurrentOpenSockets().putIfAbsent(clientId,new HashMap<>());
            projectRegistry.getCurrentOpenSockets().get(clientId).put(user.getDywaId(),session);
        } else {
            session.close();
        }
    }

    public void send(long projectId,WebSocketMessage message)
    {
        projectRegistry.send(projectId,message);
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        LOGGER.log(Level.INFO, "New message from Client [{0}]: {1}",
                new Object[] {session.getId(), message});
    }

    @OnClose
    public void onClose(Session session) {
        long userId = Long.parseLong(session.getUserPrincipal().getName());
        this.projectRegistry.getCurrentOpenSockets().values().removeIf(n->n.containsKey(userId));
        LOGGER.log(Level.INFO, "Close project connection for client: {0}",
                session.getId());
    }

    @OnError
    public void onError(Throwable exception, Session session) {
        LOGGER.log(Level.INFO, "Error for project client: {0}", session.getId());
    }

    /**
     * Closes all open sockets to users, not contained in the allowedUsersList
     * for the given project
     * @param projectDywaId ID of the project
     * @param allowedUserList IDs of the allowed users for the project
     */
    public void updateUserList(long projectDywaId, List<Long> allowedUserList){
        if(this.projectRegistry.getCurrentOpenSockets().containsKey(projectDywaId))
        {
            Stream<Map.Entry<Long, Session>> socketsToClose = this.projectRegistry.getCurrentOpenSockets()
                    .get(projectDywaId).entrySet().stream().filter(n->!allowedUserList.contains(n.getKey()));
            socketsToClose
                    .forEach((w) -> {
                        try {
                            System.out.println("[PYRO] Closing WebSocket with code 4000 after deleting user from allowed list.");
                            projectRegistry.close(w.getValue(),4001);
                        } catch(Exception e) {
                            e.printStackTrace();
                        }
                        this.projectRegistry.getCurrentOpenSockets().get(projectDywaId).remove(w);
                    });


        }
    }

}
