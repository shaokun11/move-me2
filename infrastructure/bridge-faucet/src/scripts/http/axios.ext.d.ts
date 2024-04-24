import {
  AxiosInstance,
  AxiosRequestConfig,
  AxiosResponse,
  AxiosError,
} from 'axios'

declare module 'axios/index' {
  interface AxiosInstance {
   
    exHooks: Array<{
      onBefore?: (config: AxiosRequestConfig) => any

      onComplete?: (
        config: AxiosRequestConfig,
        isResolve: boolean,
        resOrErr: AxiosResponse | AxiosError | Error | any,
      ) => any
    }> & {
      add: (obj: AxiosInstance['exHooks'][0]) => () => any
    }
  }

  interface AxiosRequestConfig {
    exNoErrorMassage?: boolean 
    exShowLoading?: boolean 

  
    exCancel?: boolean | string | Array<boolean | string>

    exCancelName?: boolean | string
  }

  interface AxiosResponse {
    exData: any 
  }
}
