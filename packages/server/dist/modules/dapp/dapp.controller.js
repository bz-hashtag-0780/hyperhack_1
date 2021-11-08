"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DappController = void 0;
const openapi = require("@nestjs/swagger");
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const dapp_service_1 = require("./dapp.service");
let DappController = class DappController {
    constructor(dappService) {
        this.dappService = dappService;
    }
    async sample(greeting) {
        return await this.dappService.sample(greeting);
    }
};
__decorate([
    common_1.Get('sample'),
    swagger_1.ApiOperation({ summary: 'Sample API end-point' }),
    openapi.ApiResponse({ status: 200, type: String }),
    __param(0, common_1.Query('greeting')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], DappController.prototype, "sample", null);
DappController = __decorate([
    swagger_1.ApiTags('Dapp'),
    common_1.Controller('api'),
    __metadata("design:paramtypes", [dapp_service_1.DappService])
], DappController);
exports.DappController = DappController;
//# sourceMappingURL=dapp.controller.js.map