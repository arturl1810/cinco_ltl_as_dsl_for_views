package info.scce.pyro.core.command;

import de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser;
import info.scce.pyro.core.command.types.Command;

import java.util.LinkedList;
import java.util.List;

/**
 * Author zweihoff
 */
public class BatchExecution {
    PyroUser user;
    List<Command> commands;
    TransactionMode mode;

    BatchExecution(PyroUser user){
        this.user = user;
        commands = new LinkedList<>();
    }

    void add(Command cmd){
        commands.add(cmd);
    }

    public PyroUser getUser() {
        return user;
    }

    public void setUser(PyroUser user) {
        this.user = user;
    }

    public List<Command> getCommands() {
        return commands;
    }

    public void setCommands(List<Command> commands) {
        this.commands = commands;
    }

    public TransactionMode getMode() {
        return mode;
    }

    public void setMode(TransactionMode mode) {
        this.mode = mode;
    }
}

enum TransactionMode {
    PROPAGATE, SILENT
}
