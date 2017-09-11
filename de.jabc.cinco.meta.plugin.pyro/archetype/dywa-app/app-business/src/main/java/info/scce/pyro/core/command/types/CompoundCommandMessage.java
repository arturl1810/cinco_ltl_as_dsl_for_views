package info.scce.pyro.core.command.types;

/**
 * Author zweihoff
 */
@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
public class CompoundCommandMessage extends GraphMessage {

    @com.fasterxml.jackson.annotation.JsonProperty("cmd")
    private CompoundCommand cmd;

    @com.fasterxml.jackson.annotation.JsonProperty("type")
    private String type;

    public CompoundCommandMessage() {
        super();
        super.setMessageType("command");
    }

    public CompoundCommand getCmd() {
        return cmd;
    }

    public void setCmd(CompoundCommand cmd) {
        this.cmd = cmd;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }
}
