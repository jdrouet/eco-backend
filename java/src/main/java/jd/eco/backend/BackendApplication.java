package jd.eco.backend;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Map;

@SpringBootApplication(exclude={DataSourceAutoConfiguration.class})
@RestController
public class BackendApplication {

	private HttpClient client;
	private String blackholeUrl;

	public static void main(String[] args) {
		SpringApplication.run(BackendApplication.class, args);
	}

	public BackendApplication() {
		Map<String, String> env = System.getenv();
		this.client = HttpClient.newHttpClient();
		this.blackholeUrl = env.get("BLACKHOLE_URL");
		if (this.blackholeUrl == null) {
			this.blackholeUrl = "http://localhost:3010";
		}
	}

	@GetMapping(path = "/")
	public void status() {
		// Nothing to do
	}

	@PostMapping(path = "/publish", consumes = MediaType.APPLICATION_JSON_VALUE)
	public void publish(@RequestBody Event event) throws IOException, InterruptedException {
		ObjectMapper mapper = new ObjectMapper();
		byte[] value = mapper.writeValueAsBytes(event);
		HttpRequest request = HttpRequest.newBuilder()
				.uri(URI.create(this.blackholeUrl))
				.header("Content-Type", "application/json")
				.POST(HttpRequest.BodyPublishers.ofByteArray(value))
				.build();
		client.send(request, HttpResponse.BodyHandlers.discarding());
	}
}
