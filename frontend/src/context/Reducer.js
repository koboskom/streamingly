import {
    SET_CURRENT_SONG,
    TOGGLE_RANDOM,
    TOGGLE_REPEAT,
    TOGGLE_PLAYING,
    SET_SONGS,
    SET_TEMP_SONGS,
    SET_ALBUM,
    SET_ARTIST

  } from './Types'
  
// eslint-disable-next-line import/no-anonymous-default-export
export default (state, action) => {
    switch (action.type) {
      case SET_CURRENT_SONG:
        return {
          ...state,
          currentSong: action.data,
          playing: true
        }
      case TOGGLE_RANDOM:
        return {
          ...state,
          random: action.data
        }
      case TOGGLE_REPEAT:
        return {
          ...state,
          repeat: action.data
        }
      case TOGGLE_PLAYING:
        return {
          ...state,
          playing: action.data
        }
      case SET_SONGS: 
        return {
          ...state,
          songs: action.data,
          
        }
        case SET_TEMP_SONGS: 
        return {
          ...state,
          tempSongs: action.data,
          
        }
      case SET_ARTIST: 
        return {
          ...state,
          artists: action.data,
          
        }
      case SET_ALBUM: 
      return {
        ...state,
        albums: action.data,
        
      }
      default:
        return state
    }
  
  }
  