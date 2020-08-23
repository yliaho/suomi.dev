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

/**
 * @returns {HTMLElement} 
 */
function getVotesAmountNode(target) {
  return target.querySelector('span')
}

function incVotesAmountNodeTextContent(target, value) {
  const amount = getVotesAmountNode(target)

  if (amount) {
    amount.textContent = parseInt(amount.textContent) + value
  }
}

function likeSubmission(target) {
  const submissionId = getSubmissionId(target)
  toggleDatasetLiked(target)
  incVotesAmountNodeTextContent(target, 1)

  PhxRequest.post(`/api/votes/${submissionId}`, null).then(res => {
    if (!isOk(res)) {
      toggleDatasetLiked(target)
    }
  }).catch(() => {
    toggleDatasetLiked(target)
    incVotesAmountNodeTextContent(target, -1)
  })
}

function unlikeSubmission(target) {
  const submissionId = getSubmissionId(target)
  toggleDatasetLiked(target)
  incVotesAmountNodeTextContent(target, -1)

  PhxRequest.delete(`/api/votes/${submissionId}`, null).then(res => {
    if (!isOk(res)) {
      toggleDatasetLiked(target)
    }
  }).catch(() => {
    toggleDatasetLiked(target)
    incVotesAmountNodeTextContent(target, 1)
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