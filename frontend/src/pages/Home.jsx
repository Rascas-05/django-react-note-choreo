import { useState, useEffect } from "react"
import api from "../api"
import "../styles/Home.css"
import Note from "../components/Note"

function Home() {
    const [notes, setNotes] = useState([]);
    const [content, setContent] = useState("");
    const [title, setTitle] = useState("");
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    useEffect(() => {
        getNotes();
    }, [])

    const getNotes = async () => {
        try {
            setLoading(true);
            setError(null);
            
            //console.log("🚀 Making request to:", api.defaults.baseURL + "/api/notes");
            
            const response = await api.get("/api/notes");
            
            //console.log("✅ Response status:", response.status);
            //console.log("✅ Response headers:", response.headers);
            //console.log("✅ Response data:", response.data);
            
            setNotes(response.data);
            
        } catch (err) {
            //console.error("❌ Request failed:");
            //console.error("Error object:", err);
            
            if (err.response) {
                // Server responded with error status (4xx, 5xx)
                //console.error("📡 Server Error Response:");
                //console.error("Status:", err.response.status);
                //console.error("Headers:", err.response.headers);
                //console.error("Data:", err.response.data);
                setError(`Server Error: ${err.response.status} - ${err.response.data?.detail || 'Unknown error'}`);
                
            } else if (err.request) {
                // Request was made but no response (network/CORS issue)
                //console.error("🌐 Network/CORS Error:");
                //console.error("Request:", err.request);
                setError("Network Error: Could not reach server (likely CORS or network issue)");
                
            } else {
                // Something else happened
                //console.error("⚠️ Other Error:", err.message);
                setError(`Error: ${err.message}`);
            }
            
        } finally {
            setLoading(false);
        }
    };

    const createNote = (e) => {
        e.preventDefault();
        api
            .post("/api/notes/", { content, title })
            .then((res) => {
                if (res.status === 201) alert("Note created!");
                else alert("Failed to make note.");
                getNotes();
            })
            .catch((err) => alert(err));
    }

    const deleteNote = (id) => {
        api
            .delete(`/api/notes/delete/${id}/`)
            .then((res) => {
                if (res.status === 204) alert("Note deleted!");
                else alert("Failed to delete note.");
                getNotes();
            })
            .catch((error) => alert(error));
    };

    return (
        <div>
            <div>
                <h2>Notes</h2>
                {notes.map((note) => (
                    <Note note={note} onDelete={deleteNote} key={note.id} />
                ))}
            </div>
            <h2>Create a Note</h2>
            <form onSubmit={createNote}>
                <label htmlFor="title">Title:</label>
                <br />
                <input
                    type="text"
                    id="title"
                    name="title"
                    required
                    onChange={(e) => setTitle(e.target.value)}
                    value={title}
                />
                <label htmlFor="content">Content:</label>
                <br />
                <textarea
                    id="content"
                    name="content"
                    required
                    value={content}
                    onChange={(e) => setContent(e.target.value)}
                ></textarea>
                <br />
                <input type="submit" value="Submit"></input>
            </form>
        </div>
    );
}

export default Home;