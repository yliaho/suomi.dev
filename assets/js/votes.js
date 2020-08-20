import {PhxRequest} from './phx-request'

/**
 * @param {HTMLButtonElement} target 
 */
function getSubmissionId(target) {
  return target.dataset.submissionId
}

/**
 * @param {HTMLButtonElement} target 
 */
function toggleDatasetLiked(target) {
  target.classList.toggle("liked")
  target.toggleAttribute("data-liked")
}

/**
 * @param {HTMLButtonElement} target 
 */
function isLiked(target) {
  return "liked" in target.dataset
}

function isOk(res) {
  return res.ok
}

function likeSubmission(target) {
  const submissionId = getSubmissionId(target)
  toggleDatasetLiked(target)

  PhxRequest.post(`/api/votes/${submissionId}`, null).then(res => {
    if (!isOk(res)) {
      toggleDatasetLiked(target)
    }
  }).catch(() => {
    toggleDatasetLiked(target)
  })
}

function unlikeSubmission(target) {
  const submissionId = getSubmissionId(target)
  toggleDatasetLiked(target)

  PhxRequest.delete(`/api/votes/${submissionId}`, null).then(res => {
    if (!isOk(res)) {
      toggleDatasetLiked(target)
    }
  }).catch(() => {
    toggleDatasetLiked(target)
  })
}

function handleVoteButtonClick(event) {
  if (isLiked(event.target)) {
    unlikeSubmission(event.target)
  } else {
    likeSubmission(event.target)
  }
}

export function createVoteButtons({selector}) {
  /** @type {NodeListOf<HTMLButtonElement>} */
  const buttons = document.querySelectorAll(selector)

  buttons.forEach((button) => {
    button.addEventListener("click", (event) => {
      if (event.target !== button) {
        return
      }

      handleVoteButtonClick(event)
    }, true)
  })
}