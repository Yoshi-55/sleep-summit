import { application } from "./application"

import HelloController from "./hello_controller"
import FlashController from "./flash_controller"

application.register("hello", HelloController)
application.register("flash", FlashController)
