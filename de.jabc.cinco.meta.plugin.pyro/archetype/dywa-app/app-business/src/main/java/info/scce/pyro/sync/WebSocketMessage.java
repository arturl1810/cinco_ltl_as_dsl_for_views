package info.scce.pyro.sync;

/**
 * Author zweihoff
 */

@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
public class WebSocketMessage
{


    private long senderId;

    @com.fasterxml.jackson.annotation.JsonProperty("senderId")
    public long getsenderId() {
        return this.senderId;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("senderId")
    public void setsenderId(final long senderId) {
        this.senderId = senderId;
    }


    private Object content;

    @com.fasterxml.jackson.annotation.JsonProperty("content")
    public Object getcontent() {
        return this.content;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("content")
    public void setcontent(final Object content) {
        this.content = content;
    }


    public static WebSocketMessage fromDywaEntity(final long userId,Object content) {

        final WebSocketMessage result;
        result = new WebSocketMessage();
        result.setsenderId(userId);
        result.setcontent(content);
        return result;
    }
}
