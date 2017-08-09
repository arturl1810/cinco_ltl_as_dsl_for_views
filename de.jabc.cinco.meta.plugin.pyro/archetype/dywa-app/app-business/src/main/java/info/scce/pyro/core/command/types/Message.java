package info.scce.pyro.core.command.types;

/**
 * Author zweihoff
 */
@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public abstract class Message {
    @com.fasterxml.jackson.annotation.JsonProperty("messageType")
    private String messageType;
    @com.fasterxml.jackson.annotation.JsonProperty("senderDywaId")
    private long senderDywaId;

    public String getMessageType() {
        return messageType;
    }

    public void setMessageType(String messageType) {
        this.messageType = messageType;
    }

    public long getSenderDywaId() {
        return senderDywaId;
    }

    public void setSenderDywaId(long senderDywaId) {
        this.senderDywaId = senderDywaId;
    }
}
