package enums

type SubmissionVerdict string

type SubmissionVerdictID int

const (
	SubmissionVerdictUnknownID             SubmissionVerdictID = 0
	SubmissionVerdictAcceptedID            SubmissionVerdictID = 1
	SubmissionVerdictWrongAnswerID         SubmissionVerdictID = 2
	SubmissionVerdictTimeLimitExceededID   SubmissionVerdictID = 3
	SubmissionVerdictMemoryLimitExceededID SubmissionVerdictID = 4
	SubmissionVerdictRuntimeErrorID        SubmissionVerdictID = 5
	SubmissionVerdictCompilationErrorID    SubmissionVerdictID = 6
)

const (
	SubmissionVerdictUnknown             SubmissionVerdict = "unknown"
	SubmissionVerdictAccepted            SubmissionVerdict = "accepted"
	SubmissionVerdictWrongAnswer         SubmissionVerdict = "wrong_answer"
	SubmissionVerdictTimeLimitExceeded   SubmissionVerdict = "time_limit_exceeded"
	SubmissionVerdictMemoryLimitExceeded SubmissionVerdict = "memory_limit_exceeded"
	SubmissionVerdictRuntimeError        SubmissionVerdict = "runtime_error"
	SubmissionVerdictCompilationError    SubmissionVerdict = "compilation_error"
)

func (v SubmissionVerdict) IsValid() bool {
	switch v {
	case SubmissionVerdictAccepted, SubmissionVerdictWrongAnswer, SubmissionVerdictTimeLimitExceeded, SubmissionVerdictMemoryLimitExceeded, SubmissionVerdictRuntimeError, SubmissionVerdictCompilationError:
		return true
	default:
		return false
	}
}

// ID returns a stable numeric ID, or 0 for unknown values.
func (v SubmissionVerdict) ID() SubmissionVerdictID {
	switch v {
	case SubmissionVerdictAccepted:
		return SubmissionVerdictAcceptedID
	case SubmissionVerdictWrongAnswer:
		return SubmissionVerdictWrongAnswerID
	case SubmissionVerdictTimeLimitExceeded:
		return SubmissionVerdictTimeLimitExceededID
	case SubmissionVerdictMemoryLimitExceeded:
		return SubmissionVerdictMemoryLimitExceededID
	case SubmissionVerdictRuntimeError:
		return SubmissionVerdictRuntimeErrorID
	case SubmissionVerdictCompilationError:
		return SubmissionVerdictCompilationErrorID
	default:
		return SubmissionVerdictUnknownID
	}
}

// SubmissionVerdictFromID returns Unknown for unrecognized IDs.
func SubmissionVerdictFromID(id SubmissionVerdictID) SubmissionVerdict {
	switch id {
	case SubmissionVerdictAcceptedID:
		return SubmissionVerdictAccepted
	case SubmissionVerdictWrongAnswerID:
		return SubmissionVerdictWrongAnswer
	case SubmissionVerdictTimeLimitExceededID:
		return SubmissionVerdictTimeLimitExceeded
	case SubmissionVerdictMemoryLimitExceededID:
		return SubmissionVerdictMemoryLimitExceeded
	case SubmissionVerdictRuntimeErrorID:
		return SubmissionVerdictRuntimeError
	case SubmissionVerdictCompilationErrorID:
		return SubmissionVerdictCompilationError
	default:
		return SubmissionVerdictUnknown
	}
}
