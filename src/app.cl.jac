import from react {useState, useEffect}
import from @jac-client/react {useState, useEffect}
import from @jac-client/utils {jacSpawn, jacIsLoggedIn}


# Main App Component
def app() -> any {
    let [currentView, setCurrentView] = useState("dashboard");
    let [entries, setEntries] = useState([]);
    let [mentalStates, setMentalStates] = useState([]);
    let [isLoggedIn, setIsLoggedIn] = useState(False);
    
    useEffect(lambda -> None {
        let loggedIn = jacIsLoggedIn();
        setIsLoggedIn(loggedIn);
    }, []);
    
    if not isLoggedIn {
        return <LoginView onLogin={lambda -> None {
            setIsLoggedIn(True);
        }} />;
    }
    
    return <div className="app-container">
        <Header 
            currentView={currentView} 
            setCurrentView={setCurrentView}
        />
        <main className="main-content">
            {currentView === "dashboard" && <Dashboard />}
            {currentView === "journal" && <JournalView />}
            {currentView === "mood" && <MoodTracker />}
            {currentView === "insights" && <InsightsView />}
        </main>
        <style>{`
            * { box-sizing: border-box; margin: 0; padding: 0; }
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
            .app-container { min-height: 100vh; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
            .main-content { padding: 2rem; max-width: 1200px; margin: 0 auto; }
        `}</style>
    </div>;
}

# Header Component
def Header({currentView, setCurrentView}) -> any {
    return <header style={{
        background: "rgba(255, 255, 255, 0.95)",
        padding: "1rem 2rem",
        boxShadow: "0 2px 10px rgba(0,0,0,0.1)",
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center"
    }}>
        <h1 style={{fontSize: "1.5rem", color: "#667eea"}}>
            🧠 Mental Health Journal
        </h1>
        <nav style={{display: "flex", gap: "1rem"}}>
            <NavButton 
                label="Dashboard" 
                active={currentView === "dashboard"}
                onClick={lambda e: any -> None { setCurrentView("dashboard"); }}
            />
            <NavButton 
                label="Journal" 
                active={currentView === "journal"}
                onClick={lambda e: any -> None { setCurrentView("journal"); }}
            />
            <NavButton 
                label="Mood Tracker" 
                active={currentView === "mood"}
                onClick={lambda e: any -> None { setCurrentView("mood"); }}
            />
            <NavButton 
                label="Insights" 
                active={currentView === "insights"}
                onClick={lambda e: any -> None { setCurrentView("insights"); }}
            />
        </nav>
    </header>;
}

# Navigation Button
def NavButton({label, active, onClick}) -> any {
    return <button onClick={onClick} style={{
        padding: "0.5rem 1rem",
        border: "none",
        background: active ? "#667eea" : "transparent",
        color: active ? "white" : "#333",
        borderRadius: "8px",
        cursor: "pointer",
        fontWeight: active ? "600" : "400",
        transition: "all 0.3s"
    }}>
        {label}
    </button>;
}

# Dashboard View
def Dashboard() -> any {
    let [stats, setStats] = useState(None);
    let [loading, setLoading] = useState(True);
    
    useEffect(lambda -> None {
        setLoading(False);
        setStats({
            totalEntries: 12,
            weeklyMood: 7.2,
            stressLevel: 4.5
        });
    }, []);
    
    if loading {
        return <div style={{textAlign: "center", padding: "3rem", color: "white"}}>
            Loading...
        </div>;
    }
    
    return <div style={{display: "grid", gap: "1.5rem"}}>
        <h2 style={{color: "white", fontSize: "2rem"}}>Dashboard</h2>
        <div style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(250px, 1fr))",
            gap: "1.5rem"
        }}>
            <StatCard 
                icon="📝" 
                title="Journal Entries" 
                value={stats.totalEntries}
                subtitle="Total entries"
            />
            <StatCard 
                icon="😊" 
                title="Weekly Mood" 
                value={stats.weeklyMood}
                subtitle="Average this week"
            />
            <StatCard 
                icon="💆" 
                title="Stress Level" 
                value={stats.stressLevel}
                subtitle="Current level"
            />
        </div>
    </div>;
}

# Stat Card Component
def StatCard({icon, title, value, subtitle}) -> any {
    return <div style={{
        background: "white",
        borderRadius: "12px",
        padding: "1.5rem",
        boxShadow: "0 4px 6px rgba(0,0,0,0.1)"
    }}>
        <div style={{fontSize: "2rem", marginBottom: "0.5rem"}}>{icon}</div>
        <h3 style={{fontSize: "1rem", color: "#666", marginBottom: "0.5rem"}}>{title}</h3>
        <div style={{fontSize: "2rem", fontWeight: "bold", color: "#667eea"}}>{value}</div>
        <p style={{fontSize: "0.875rem", color: "#999", marginTop: "0.25rem"}}>{subtitle}</p>
    </div>;
}

# Journal View
def JournalView() -> any {
    let [entries, setEntries] = useState([]);
    let [showForm, setShowForm] = useState(False);
    
    return <div style={{display: "grid", gap: "1.5rem"}}>
        <div style={{display: "flex", justifyContent: "space-between", alignItems: "center"}}>
            <h2 style={{color: "white", fontSize: "2rem"}}>Journal Entries</h2>
            <button onClick={lambda e: any -> None { setShowForm(not showForm); }} style={{
                padding: "0.75rem 1.5rem",
                background: "white",
                border: "none",
                borderRadius: "8px",
                cursor: "pointer",
                fontWeight: "600",
                color: "#667eea"
            }}>
                {showForm ? "Cancel" : "+ New Entry"}
            </button>
        </div>
        
        {showForm && <JournalEntryForm onSubmit={lambda entry: any -> None {
            setEntries([...entries, entry]);
            setShowForm(False);
        }} />}
        
        <div style={{display: "grid", gap: "1rem"}}>
            {len(entries) === 0 && not showForm && <div style={{
                background: "white",
                borderRadius: "12px",
                padding: "3rem",
                textAlign: "center",
                color: "#999"
            }}>
                No journal entries yet. Click "New Entry" to get started!
            </div>}
            
            {entries.map(lambda entry, idx: any -> any {
                return <JournalEntryCard key={idx} entry={entry} />;
            })}
        </div>
    </div>;
}

# Journal Entry Form
def JournalEntryForm({onSubmit}) -> any {
    let [title, setTitle] = useState("");
    let [content, setContent] = useState("");
    
    def handleSubmit(e) -> None {
        e.preventDefault();
        if title && content {
            onSubmit({
                title: title,
                content: content,
                date: Date.now()
            });
            setTitle("");
            setContent("");
        }
    }
    
    return <form onSubmit={handleSubmit} style={{
        background: "white",
        borderRadius: "12px",
        padding: "1.5rem",
        display: "grid",
        gap: "1rem"
    }}>
        <input 
            type="text"
            placeholder="Entry title..."
            value={title}
            onChange={lambda e: any -> None { setTitle(e.target.value); }}
            style={{
                padding: "0.75rem",
                border: "2px solid #e0e0e0",
                borderRadius: "8px",
                fontSize: "1rem"
            }}
        />
        <textarea 
            placeholder="How are you feeling today?..."
            value={content}
            onChange={lambda e: any -> None { setContent(e.target.value); }}
            rows={6}
            style={{
                padding: "0.75rem",
                border: "2px solid #e0e0e0",
                borderRadius: "8px",
                fontSize: "1rem",
                resize: "vertical"
            }}
        />
        <button type="submit" style={{
            padding: "0.75rem",
            background: "#667eea",
            color: "white",
            border: "none",
            borderRadius: "8px",
            cursor: "pointer",
            fontWeight: "600",
            fontSize: "1rem"
        }}>
            Save Entry
        </button>
    </form>;
}

# Journal Entry Card
def JournalEntryCard({entry}) -> any {
    return <div style={{
        background: "white",
        borderRadius: "12px",
        padding: "1.5rem",
        boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
    }}>
        <h3 style={{fontSize: "1.25rem", marginBottom: "0.5rem", color: "#333"}}>
            {entry.title}
        </h3>
        <p style={{color: "#666", lineHeight: "1.5"}}>
            {entry.content}
        </p>
        <div style={{marginTop: "1rem", fontSize: "0.875rem", color: "#999"}}>
            {new Date(entry.date).toLocaleDateString()}
        </div>
    </div>;
}

# Mood Tracker View
def MoodTracker() -> any {
    let [currentMood, setCurrentMood] = useState(5);
    
    return <div style={{display: "grid", gap: "1.5rem"}}>
        <h2 style={{color: "white", fontSize: "2rem"}}>Mood Tracker</h2>
        <div style={{
            background: "white",
            borderRadius: "12px",
            padding: "2rem",
            textAlign: "center"
        }}>
            <h3 style={{marginBottom: "1rem", color: "#333"}}>How are you feeling today?</h3>
            <div style={{fontSize: "3rem", marginBottom: "1rem"}}>
                {currentMood <= 3 ? "😢" : currentMood <= 6 ? "😐" : "😊"}
            </div>
            <input 
                type="range"
                min="1"
                max="10"
                value={currentMood}
                onChange={lambda e: any -> None { setCurrentMood(parseInt(e.target.value)); }}
                style={{width: "100%", marginBottom: "1rem"}}
            />
            <div style={{color: "#667eea", fontWeight: "600", fontSize: "1.25rem"}}>
                {currentMood}/10
            </div>
        </div>
    </div>;
}

# Insights View
def InsightsView() -> any {
    return <div style={{display: "grid", gap: "1.5rem"}}>
        <h2 style={{color: "white", fontSize: "2rem"}}>Insights</h2>
        <div style={{
            background: "white",
            borderRadius: "12px",
            padding: "2rem",
            textAlign: "center"
        }}>
            <p style={{color: "#666", fontSize: "1.125rem"}}>
                Insights and analytics coming soon...
            </p>
        </div>
    </div>;
}

# Login View
def LoginView({onLogin}) -> any {
    return <div style={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)"
    }}>
        <div style={{
            background: "white",
            borderRadius: "12px",
            padding: "3rem",
            textAlign: "center",
            maxWidth: "400px",
            width: "90%"
        }}>
            <h1 style={{fontSize: "2rem", marginBottom: "1rem", color: "#667eea"}}>
                🧠 Mental Health Journal
            </h1>
            <p style={{color: "#666", marginBottom: "2rem"}}>
                Track your mental wellness journey
            </p>
            <button onClick={onLogin} style={{
                padding: "1rem 2rem",
                background: "#667eea",
                color: "white",
                border: "none",
                borderRadius: "8px",
                cursor: "pointer",
                fontWeight: "600",
                fontSize: "1rem",
                width: "100%"
            }}>
                Get Started
            </button>
        </div>
    </div>;
}