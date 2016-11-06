package net.piotrl.music.aggregation.lastfm;

import de.umass.lastfm.PaginatedResult;
import de.umass.lastfm.Track;
import de.umass.lastfm.User;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class LastFmConnector {

    // TODO: @Value doesn't work in tests
    @Value("${aggregation.lastfm.api_key}")
    private String api_key = "5f062176c25b0c3570a65bca887188f8";

    @Value("${aggregation.lastfm.secure}")
    private String secure = "680127560c4190a9ce1c1785fb82d684";

    @Value("${aggregation.lastfm.username}")
    private String username = "grovman";

    public LastFmConnector() {}

    public LastFmConnector(String username, String api_key) {
        this.username = username;
        this.api_key = api_key;
    }

    public LastFmAuthProperties properties() {
        return new LastFmAuthProperties(api_key, secure, username);
    }

    public User getUserInfo() {
        return User.getInfo(this.username, this.api_key);
    }

    public PaginatedResult<Track> getUserTracksFromLastDay() {
        return User.getRecentTracks(this.username, this.api_key);
    }
}