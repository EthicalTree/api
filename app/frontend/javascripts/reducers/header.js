
const header = (state={}, action) => {

  switch (action.type) {
    case 'TOGGLE_HEADER_ACCESSIBLE':
      return {...state, isOpen: !state.isOpen}
    default:
      return state
  }

}

export default header
