package enums_test

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/Orodss/baseJudge/domain/enums"
)

func TestUserRole(t *testing.T) {
	reverse := map[enums.UserRoleID]enums.UserRole{
		enums.UserRoleUnknownID: enums.UserRoleUnknown,
		enums.UserRoleAdminID:   enums.UserRoleAdmin,
		enums.UserRoleGuestID:   enums.UserRoleGuest,
		-1:                      enums.UserRoleUnknown,
		999:                     enums.UserRoleUnknown,
	}
	for id, want := range reverse {
		if got := enums.UserRoleFromID(id); got != want {
			t.Errorf("UserRoleFromID(%d) = %q; want %q", id, got, want)
		}
		if want.IsValid() && want.ID() != id {
			t.Errorf("%q.ID() = %d; want %d", want, want.ID(), id)
		}
	}
	ids := map[enums.UserRole]enums.UserRoleID{
		enums.UserRoleUnknown: 0,
		enums.UserRoleAdmin:   1,
		enums.UserRoleGuest:   2,
		"":                    0,
		"future_category":     0,
	}
	for value, want := range ids {
		if got := value.ID(); got != want {
			t.Errorf("%q.ID() = %d; want %d", value, got, want)
		}
	}
	if enums.UserRoleUnknown != "unknown" || enums.UserRoleUnknown.IsValid() {
		t.Fatal("Unknown must be the invalid sentinel string unknown")
	}
	valid := map[enums.UserRole]string{
		enums.UserRoleAdmin: "admin",
		enums.UserRoleGuest: "guest",
	}
	for value, want := range valid {
		t.Run(want, func(t *testing.T) {
			if string(value) != want || !value.IsValid() {
				t.Fatalf("value = %q, valid = %v; want %q, true", value, value.IsValid(), want)
			}
			data, err := json.Marshal(value)
			if err != nil || string(data) != "\""+want+"\"" {
				t.Fatalf("Marshal = %s, %v; want quoted %q", data, err, want)
			}
			for _, invalid := range []string{strings.ToUpper(want), " " + want, want + " "} {
				if enums.UserRole(invalid).IsValid() {
					t.Errorf("%q should be invalid", invalid)
				}
			}
		})
	}
	for _, invalid := range []enums.UserRole{"", "unknown", "accepted"} {
		if invalid.IsValid() {
			t.Errorf("%q should be invalid", invalid)
		}
	}
	var decoded enums.UserRole
	if err := json.Unmarshal([]byte(`"unknown"`), &decoded); err != nil {
		t.Fatal(err)
	}
	if decoded.IsValid() {
		t.Fatal("decoded unknown value should be invalid")
	}
}

func TestPublicationStatus(t *testing.T) {
	reverse := map[enums.PublicationStatusID]enums.PublicationStatus{
		enums.PublicationStatusUnknownID:   enums.PublicationStatusUnknown,
		enums.PublicationStatusDraftID:     enums.PublicationStatusDraft,
		enums.PublicationStatusPublishedID: enums.PublicationStatusPublished,
		enums.PublicationStatusArchivedID:  enums.PublicationStatusArchived,
		-1:                                 enums.PublicationStatusUnknown,
		999:                                enums.PublicationStatusUnknown,
	}
	for id, want := range reverse {
		if got := enums.PublicationStatusFromID(id); got != want {
			t.Errorf("PublicationStatusFromID(%d) = %q; want %q", id, got, want)
		}
		if want.IsValid() && want.ID() != id {
			t.Errorf("%q.ID() = %d; want %d", want, want.ID(), id)
		}
	}
	ids := map[enums.PublicationStatus]enums.PublicationStatusID{
		enums.PublicationStatusUnknown:   0,
		enums.PublicationStatusDraft:     1,
		enums.PublicationStatusPublished: 2,
		enums.PublicationStatusArchived:  3,
		"":                               0,
		"future_category":                0,
	}
	for value, want := range ids {
		if got := value.ID(); got != want {
			t.Errorf("%q.ID() = %d; want %d", value, got, want)
		}
	}
	if enums.PublicationStatusUnknown != "unknown" || enums.PublicationStatusUnknown.IsValid() {
		t.Fatal("Unknown must be the invalid sentinel string unknown")
	}
	valid := map[enums.PublicationStatus]string{
		enums.PublicationStatusDraft:     "draft",
		enums.PublicationStatusPublished: "published",
		enums.PublicationStatusArchived:  "archived",
	}
	for value, want := range valid {
		t.Run(want, func(t *testing.T) {
			if string(value) != want || !value.IsValid() {
				t.Fatalf("value = %q, valid = %v; want %q, true", value, value.IsValid(), want)
			}
			data, err := json.Marshal(value)
			if err != nil || string(data) != "\""+want+"\"" {
				t.Fatalf("Marshal = %s, %v; want quoted %q", data, err, want)
			}
			for _, invalid := range []string{strings.ToUpper(want), " " + want, want + " "} {
				if enums.PublicationStatus(invalid).IsValid() {
					t.Errorf("%q should be invalid", invalid)
				}
			}
		})
	}
	for _, invalid := range []enums.PublicationStatus{"", "unknown", "accepted"} {
		if invalid.IsValid() {
			t.Errorf("%q should be invalid", invalid)
		}
	}
	var decoded enums.PublicationStatus
	if err := json.Unmarshal([]byte(`"unknown"`), &decoded); err != nil {
		t.Fatal(err)
	}
	if decoded.IsValid() {
		t.Fatal("decoded unknown value should be invalid")
	}
}

func TestContestPhase(t *testing.T) {
	reverse := map[enums.ContestPhaseID]enums.ContestPhase{
		enums.ContestPhaseUnknownID:  enums.ContestPhaseUnknown,
		enums.ContestPhaseUpcomingID: enums.ContestPhaseUpcoming,
		enums.ContestPhaseRunningID:  enums.ContestPhaseRunning,
		enums.ContestPhaseEndedID:    enums.ContestPhaseEnded,
		-1:                           enums.ContestPhaseUnknown,
		999:                          enums.ContestPhaseUnknown,
	}
	for id, want := range reverse {
		if got := enums.ContestPhaseFromID(id); got != want {
			t.Errorf("ContestPhaseFromID(%d) = %q; want %q", id, got, want)
		}
		if want.IsValid() && want.ID() != id {
			t.Errorf("%q.ID() = %d; want %d", want, want.ID(), id)
		}
	}
	ids := map[enums.ContestPhase]enums.ContestPhaseID{
		enums.ContestPhaseUnknown:  0,
		enums.ContestPhaseUpcoming: 1,
		enums.ContestPhaseRunning:  2,
		enums.ContestPhaseEnded:    3,
		"":                         0,
		"future_category":          0,
	}
	for value, want := range ids {
		if got := value.ID(); got != want {
			t.Errorf("%q.ID() = %d; want %d", value, got, want)
		}
	}
	if enums.ContestPhaseUnknown != "unknown" || enums.ContestPhaseUnknown.IsValid() {
		t.Fatal("Unknown must be the invalid sentinel string unknown")
	}
	valid := map[enums.ContestPhase]string{
		enums.ContestPhaseUpcoming: "upcoming",
		enums.ContestPhaseRunning:  "running",
		enums.ContestPhaseEnded:    "ended",
	}
	for value, want := range valid {
		t.Run(want, func(t *testing.T) {
			if string(value) != want || !value.IsValid() {
				t.Fatalf("value = %q, valid = %v; want %q, true", value, value.IsValid(), want)
			}
			data, err := json.Marshal(value)
			if err != nil || string(data) != "\""+want+"\"" {
				t.Fatalf("Marshal = %s, %v; want quoted %q", data, err, want)
			}
			for _, invalid := range []string{strings.ToUpper(want), " " + want, want + " "} {
				if enums.ContestPhase(invalid).IsValid() {
					t.Errorf("%q should be invalid", invalid)
				}
			}
		})
	}
	for _, invalid := range []enums.ContestPhase{"", "unknown", "accepted"} {
		if invalid.IsValid() {
			t.Errorf("%q should be invalid", invalid)
		}
	}
	var decoded enums.ContestPhase
	if err := json.Unmarshal([]byte(`"unknown"`), &decoded); err != nil {
		t.Fatal(err)
	}
	if decoded.IsValid() {
		t.Fatal("decoded unknown value should be invalid")
	}
}

func TestSubmissionStatus(t *testing.T) {
	reverse := map[enums.SubmissionStatusID]enums.SubmissionStatus{
		enums.SubmissionStatusUnknownID:  enums.SubmissionStatusUnknown,
		enums.SubmissionStatusQueuedID:   enums.SubmissionStatusQueued,
		enums.SubmissionStatusRunningID:  enums.SubmissionStatusRunning,
		enums.SubmissionStatusFinishedID: enums.SubmissionStatusFinished,
		enums.SubmissionStatusFailedID:   enums.SubmissionStatusFailed,
		-1:                               enums.SubmissionStatusUnknown,
		999:                              enums.SubmissionStatusUnknown,
	}
	for id, want := range reverse {
		if got := enums.SubmissionStatusFromID(id); got != want {
			t.Errorf("SubmissionStatusFromID(%d) = %q; want %q", id, got, want)
		}
		if want.IsValid() && want.ID() != id {
			t.Errorf("%q.ID() = %d; want %d", want, want.ID(), id)
		}
	}
	ids := map[enums.SubmissionStatus]enums.SubmissionStatusID{
		enums.SubmissionStatusUnknown:  0,
		enums.SubmissionStatusQueued:   1,
		enums.SubmissionStatusRunning:  2,
		enums.SubmissionStatusFinished: 3,
		enums.SubmissionStatusFailed:   4,
		"":                             0,
		"future_category":              0,
	}
	for value, want := range ids {
		if got := value.ID(); got != want {
			t.Errorf("%q.ID() = %d; want %d", value, got, want)
		}
	}
	if enums.SubmissionStatusUnknown != "unknown" || enums.SubmissionStatusUnknown.IsValid() {
		t.Fatal("Unknown must be the invalid sentinel string unknown")
	}
	valid := map[enums.SubmissionStatus]string{
		enums.SubmissionStatusQueued:   "queued",
		enums.SubmissionStatusRunning:  "running",
		enums.SubmissionStatusFinished: "finished",
		enums.SubmissionStatusFailed:   "failed",
	}
	for value, want := range valid {
		t.Run(want, func(t *testing.T) {
			if string(value) != want || !value.IsValid() {
				t.Fatalf("value = %q, valid = %v; want %q, true", value, value.IsValid(), want)
			}
			data, err := json.Marshal(value)
			if err != nil || string(data) != "\""+want+"\"" {
				t.Fatalf("Marshal = %s, %v; want quoted %q", data, err, want)
			}
			for _, invalid := range []string{strings.ToUpper(want), " " + want, want + " "} {
				if enums.SubmissionStatus(invalid).IsValid() {
					t.Errorf("%q should be invalid", invalid)
				}
			}
		})
	}
	for _, invalid := range []enums.SubmissionStatus{"", "unknown", "accepted"} {
		if invalid.IsValid() {
			t.Errorf("%q should be invalid", invalid)
		}
	}
	var decoded enums.SubmissionStatus
	if err := json.Unmarshal([]byte(`"unknown"`), &decoded); err != nil {
		t.Fatal(err)
	}
	if decoded.IsValid() {
		t.Fatal("decoded unknown value should be invalid")
	}
}

func TestSubmissionVerdict(t *testing.T) {
	reverse := map[enums.SubmissionVerdictID]enums.SubmissionVerdict{
		enums.SubmissionVerdictUnknownID:             enums.SubmissionVerdictUnknown,
		enums.SubmissionVerdictAcceptedID:            enums.SubmissionVerdictAccepted,
		enums.SubmissionVerdictWrongAnswerID:         enums.SubmissionVerdictWrongAnswer,
		enums.SubmissionVerdictTimeLimitExceededID:   enums.SubmissionVerdictTimeLimitExceeded,
		enums.SubmissionVerdictMemoryLimitExceededID: enums.SubmissionVerdictMemoryLimitExceeded,
		enums.SubmissionVerdictRuntimeErrorID:        enums.SubmissionVerdictRuntimeError,
		enums.SubmissionVerdictCompilationErrorID:    enums.SubmissionVerdictCompilationError,
		-1:  enums.SubmissionVerdictUnknown,
		999: enums.SubmissionVerdictUnknown,
	}
	for id, want := range reverse {
		if got := enums.SubmissionVerdictFromID(id); got != want {
			t.Errorf("SubmissionVerdictFromID(%d) = %q; want %q", id, got, want)
		}
		if want.IsValid() && want.ID() != id {
			t.Errorf("%q.ID() = %d; want %d", want, want.ID(), id)
		}
	}
	ids := map[enums.SubmissionVerdict]enums.SubmissionVerdictID{
		enums.SubmissionVerdictUnknown:             0,
		enums.SubmissionVerdictAccepted:            1,
		enums.SubmissionVerdictWrongAnswer:         2,
		enums.SubmissionVerdictTimeLimitExceeded:   3,
		enums.SubmissionVerdictMemoryLimitExceeded: 4,
		enums.SubmissionVerdictRuntimeError:        5,
		enums.SubmissionVerdictCompilationError:    6,
		"":                                         0,
		"future_category":                          0,
	}
	for value, want := range ids {
		if got := value.ID(); got != want {
			t.Errorf("%q.ID() = %d; want %d", value, got, want)
		}
	}
	if enums.SubmissionVerdictUnknown != "unknown" || enums.SubmissionVerdictUnknown.IsValid() {
		t.Fatal("Unknown must be the invalid sentinel string unknown")
	}
	valid := map[enums.SubmissionVerdict]string{
		enums.SubmissionVerdictAccepted:            "accepted",
		enums.SubmissionVerdictWrongAnswer:         "wrong_answer",
		enums.SubmissionVerdictTimeLimitExceeded:   "time_limit_exceeded",
		enums.SubmissionVerdictMemoryLimitExceeded: "memory_limit_exceeded",
		enums.SubmissionVerdictRuntimeError:        "runtime_error",
		enums.SubmissionVerdictCompilationError:    "compilation_error",
	}
	for value, want := range valid {
		t.Run(want, func(t *testing.T) {
			if string(value) != want || !value.IsValid() {
				t.Fatalf("value = %q, valid = %v; want %q, true", value, value.IsValid(), want)
			}
			data, err := json.Marshal(value)
			if err != nil || string(data) != "\""+want+"\"" {
				t.Fatalf("Marshal = %s, %v; want quoted %q", data, err, want)
			}
			for _, invalid := range []string{strings.ToUpper(want), " " + want, want + " "} {
				if enums.SubmissionVerdict(invalid).IsValid() {
					t.Errorf("%q should be invalid", invalid)
				}
			}
		})
	}
	for _, invalid := range []enums.SubmissionVerdict{"", "unknown", "queued"} {
		if invalid.IsValid() {
			t.Errorf("%q should be invalid", invalid)
		}
	}
	var decoded enums.SubmissionVerdict
	if err := json.Unmarshal([]byte(`"unknown"`), &decoded); err != nil {
		t.Fatal(err)
	}
	if decoded.IsValid() {
		t.Fatal("decoded unknown value should be invalid")
	}
}
