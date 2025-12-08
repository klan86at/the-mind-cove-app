import from byllm.lib { Model }

glob llm = Model(model_name="gpt-4"); 

# walker StateAgent {
#     # This dictionary will hold the data collected during the journey.
#     has state: dict = {};

#     # The walker's journey starts at the root node.
#     can start with `root entry {
#         # From the root, visit all directly connected nodes.
#         visit [-->];
#     }
# }

walker log_mood {
    has mood_value: int;
    has trigger_tag: list=[];
    has note: str="";
}

walker update_graph_empathy {
    has emotion_name: str="";
    has emotion_intensity: int=0;
    has related_triggers: list=[];
}

walker trends {
    has time_frame: str="weekly";
}

node mood {
    has name: str="mood";
    has value: int;
    has datetime: float;
}

node trigger {
    has tag: str="trigger";
    has level: float=1.0;
}

node acticity {
    has action: str="activity";
    has duration: float=0.0;
}

node suggestion {
    has advice: str="suggestion";
    has used: bool=false;
    has reward: float=0.0;
}

node journal {
    has note: str="journal";
    has duration: float=0.0;
}

edge influences {
    has strength: float=1.0;
}

edge suggests {
    has confidence: float=1.0;
}

edge followedBy {
    has time_gap: float=0.0;
}

edge similarTo {
    has similarity_score: float=1.0;
}
# node journalEntry {
#     title: str;
#     content: str
#     date: date;

#     can get with `analyze {
#         # Analyze the journal entry content for emotional tone.
#         let emotions = analyze_emotions(self.content, self.date, self.title);
#         # Store the analysis results in the walker's state.
#         StateAgent.state["emotions"] = emotions;
#     }
# }

# node journal {
#     entries: [journalEntry];

#     can get with `summarize {
#         # Summarize the journal entries.
#         let summary = summarize_entries(self.entries);
#         # Store the summary in the walker's state.
#         StateAgent.state["summary"] = summary;
#     }
# }

# node mentalState {
#     mood: str;
#     stressLevel: int;
#     # energyLevel: int;

#     can get with `evaluate {
#         # Evaluate the mental state based on mood and stress level.
#         let evaluation = evaluate_mental_state(self.mood, self.stressLevel);
#         # Store the evaluation in the walker's state.
#         StateAgent.state["mental_evaluation"] = evaluation;
#     }
# }

# node emotion {
#     name: str;
#     intensity: int;
#     triggers: [str];

#     can get with `track {
#         # Track the emotion over time.
#         let tracking_info = track_emotion(self.name, self.intensity, self.triggers);
#         # Store the tracking info in the walker's state.
#         StateAgent.state["emotion_tracking"] = tracking_info;
#     }
# }

# # Relationships
# edge trigger {
#     cause: str;
#     intensity: int;
# }
# edge occurence {
#     state: str;
#     effect: str;
# }
# edge recordsState {
#     status: str;
# }
# edge relatedToEmotion {
#     cause: str;
#     relation: bool;
# }


# with entry {
#     root ++> journalEntry();
#     root ++> journal();
#     root ++> mentalState();
#     root ++> emotion();

#     agent = StateAgent() spawn root;
# }
