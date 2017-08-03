package info.scce.pyro.core.command.types;

import java.util.LinkedList;
import java.util.List;

/**
 * Author zweihoff
 */
@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
public class CompoundCommand {

    @com.fasterxml.jackson.annotation.JsonProperty("queue")
    java.util.List<Command> queue = new LinkedList<>();

    public List<Command> getQueue() {
        return queue;
    }

    public void setQueue(List<Command> queue) {
        this.queue = queue;
    }
}
