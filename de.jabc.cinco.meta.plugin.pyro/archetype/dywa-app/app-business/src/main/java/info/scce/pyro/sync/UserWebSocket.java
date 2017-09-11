package info.scce.pyro.sync;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.MapperFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.ser.impl.SimpleFilterProvider;
import de.ls5.dywa.generated.controller.info.scce.pyro.core.PyroUserController;
import info.scce.pyro.rest.PyroSelectiveRestFilter;

import javax.ejb.Startup;
import javax.ejb.Stateless;
import javax.inject.Inject;
import javax.inject.Named;
import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Author zweihoff
 */
@ServerEndpoint(value = "/ws/user/private")
@Named
@Startup
@Stateless
public class UserWebSocket {

    @Inject
    PyroUserController subjectController;

    @Inject
    UserRegistry userRegistry;

    private static final Logger LOGGER =
            Logger.getLogger(UserWebSocket.class.getName());

    @OnOpen
    public void open(final Session session, EndpointConfig conf) throws IOException {
        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser user = subjectController
                .read(Long.parseLong(session.getUserPrincipal().getName()));
        if(user!=null){
            userRegistry.getCurrentOpenSockets().put(user.getDywaId(),session);
        } else {
            session.close();
        }
    }

    /**
     * Sends the given serialized instance of Project to all
     * listening WebSocket connections for currentUser with the
     * given id.
     *
     * @param message	Serialized currentUser.
     */
    public void send(long receiverId,WebSocketMessage message)
    {
        userRegistry.send(receiverId,message);
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        LOGGER.log(Level.INFO, "New message from Client [{0}]: {1}",
                new Object[] {session.getId(), message});
    }

    @OnClose
    public void onClose(Session session) {
        this.userRegistry.getCurrentOpenSockets().values().remove(session);
        LOGGER.log(Level.INFO, "Close connection for client: {0}",
                session.getId());
    }

    @OnError
    public void onError(Throwable exception, Session session) {
        LOGGER.log(Level.INFO, "Error for client: {0}", session.getId());
    }


}
