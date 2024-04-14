import axios from 'axios'

const API_URL = 'https://service.horabela.com.br/api/User/updateToken?token='

export default async function sendTokenExpo(tokenHorabela, tokenExpo) {
  console.log('tokenExpo :>> ', tokenExpo)
  console.log('tokenHorabela :>> ', tokenHorabela)
  const token = axios.create({
    baseURL: API_URL,
    headers: {
      'Content-type': 'application/json',
      Authorization: 'Bearer ' + tokenHorabela,
    },
  })

  try {
    const response = await token.patch(API_URL + tokenExpo)
    if (response.status === 200) {
      console.log('Token atualizado com sucesso!')
    }
    return response
  } catch (error) {
    console.error(error)
  }
}
