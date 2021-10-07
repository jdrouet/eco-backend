package jd.eco.backend;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.util.Assert;

import java.io.IOException;
import java.util.Date;

public class LogEntryTests {

    @Test
    void deserializeString() {
        String jsonValue = "{\"createdAt\":1633619417,\"level\":\"info\",\"message\":\"hello world\"}";

        ObjectMapper mapper = new ObjectMapper();
        try {
            LogEntry entry = mapper
                    .readerFor(LogEntry.class)
                    .readValue(jsonValue);
            Assert.notNull(entry.getPayload(), "payload is null");
            Assert.isTrue(entry.getPayload().containsKey("message"), "message key is missing");
        }
        catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Test
    void deserializeNumber() {
        String jsonValue = "{\"createdAt\":1633619417,\"level\":\"info\",\"question\": 42}";

        ObjectMapper mapper = new ObjectMapper();
        try {
            LogEntry entry = mapper
                    .readerFor(LogEntry.class)
                    .readValue(jsonValue);
            Assert.notNull(entry.getPayload(), "payload is null");
            Assert.isTrue(entry.getPayload().containsKey("question"), "message key is missing");
        }
        catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Test
    void all() throws JsonProcessingException {
        String jsonValue = "{\"createdAt\":1633619417,\"level\":\"info\",\"message\":\"Hello World!\"}";
        ObjectMapper mapper = new ObjectMapper();
        LogEntry entry = mapper
                    .readerFor(LogEntry.class)
                    .readValue(jsonValue);
        String result = mapper.writeValueAsString(entry);
        Assert.isTrue(jsonValue.equals(result), "result is not same as original");
    }
}
