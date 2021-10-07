package jd.eco.backend;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.SerializerProvider;
import com.fasterxml.jackson.databind.ser.std.StdSerializer;

import java.io.IOException;
import java.util.Map;

class LogEntrySerializer extends StdSerializer<LogEntry> {
    private static final long serialVersionUID = 1L;

    public LogEntrySerializer() {
        this(null);
    }

    public LogEntrySerializer(Class<LogEntry> t) {
        super(t);
    }

    @Override
    public void serialize(LogEntry value,
                          JsonGenerator generator, SerializerProvider arg2) throws IOException {
        generator.writeStartObject();
        if (value.getId() != null) {
            generator.writeObjectField("id", value.getId());
        }
        generator.writeObjectField("createdAt", value.getCreatedAt());
        generator.writeObjectField("level", value.getLevel());
        for (Map.Entry<String, JsonNode> entry: value.getPayload().entrySet()) {
            generator.writeObjectField(entry.getKey(), entry.getValue());
        }
        generator.writeEndObject();
    }
}
