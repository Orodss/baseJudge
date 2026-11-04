package enums

type SubmissionStatus string

type SubmissionStatusID int

const (
	SubmissionStatusUnknownID  SubmissionStatusID = 0
	SubmissionStatusQueuedID   SubmissionStatusID = 1
	SubmissionStatusRunningID  SubmissionStatusID = 2
	SubmissionStatusFinishedID SubmissionStatusID = 3
	SubmissionStatusFailedID   SubmissionStatusID = 4
)

const (
	SubmissionStatusUnknown  SubmissionStatus = "unknown"
	SubmissionStatusQueued   SubmissionStatus = "queued"
	SubmissionStatusRunning  SubmissionStatus = "running"
	SubmissionStatusFinished SubmissionStatus = "finished"
	SubmissionStatusFailed   SubmissionStatus = "failed"
)

func (v SubmissionStatus) IsValid() bool {
	switch v {
	case SubmissionStatusQueued, SubmissionStatusRunning, SubmissionStatusFinished, SubmissionStatusFailed:
		return true
	default:
		return false
	}
}

// ID returns a stable numeric ID, or 0 for unknown values.
func (v SubmissionStatus) ID() SubmissionStatusID {
	switch v {
	case SubmissionStatusQueued:
		return SubmissionStatusQueuedID
	case SubmissionStatusRunning:
		return SubmissionStatusRunningID
	case SubmissionStatusFinished:
		return SubmissionStatusFinishedID
	case SubmissionStatusFailed:
		return SubmissionStatusFailedID
	default:
		return SubmissionStatusUnknownID
	}
}

// SubmissionStatusFromID returns Unknown for unrecognized IDs.
func SubmissionStatusFromID(id SubmissionStatusID) SubmissionStatus {
	switch id {
	case SubmissionStatusQueuedID:
		return SubmissionStatusQueued
	case SubmissionStatusRunningID:
		return SubmissionStatusRunning
	case SubmissionStatusFinishedID:
		return SubmissionStatusFinished
	case SubmissionStatusFailedID:
		return SubmissionStatusFailed
	default:
		return SubmissionStatusUnknown
	}
}
