import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { MongooseModule } from '@nestjs/mongoose';
import { PassportModule } from '@nestjs/passport';
import { TechnicianController } from './technician.controller';
import { TechnicianService } from './technician.service';
import { JwtStrategy } from './jwt.strategy';
import { TechnicianSchema } from './schemas/technician.schema';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        return {
          secret: config.get<string>('JWT_SECRET'),
          signOptions: {
            expiresIn: config.get<string | number>('JWT_EXPIRES'),
          },
        };
      },
    }),
    MongooseModule.forFeature([{ name: 'Technician', schema: TechnicianSchema }]),
  ],
  controllers: [TechnicianController],
  providers: [TechnicianService, JwtStrategy],
  exports: [JwtStrategy, PassportModule],
})
export class TechnicianModule {}
