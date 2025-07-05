import { Injectable, UnauthorizedException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { PassportStrategy } from '@nestjs/passport';
import { Model } from 'mongoose';
import { Strategy, ExtractJwt } from 'passport-jwt';
import { Technician } from './schemas/technician.schema';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    @InjectModel(Technician.name)
    private technicianModel: Model<Technician>,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: process.env.JWT_SECRET,
    });
  }

  async validate(payload) {
    const { id } = payload;

    const technician = await this.technicianModel.findById(id);

    if (!technician) {
      throw new UnauthorizedException('Login first to access this endpoint.');
    }

    return technician;
  }
}
